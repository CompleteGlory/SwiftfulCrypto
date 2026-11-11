//
//  HomeViewModel.swift
//  SwiftfulCrypto
//
//  Created by Magd on 24/10/2026.
//

import Foundation
import Combine
internal import UIKit

class HomeViewModel: ObservableObject {
    
    @Published var statistics: [StatisticModel] = []
    @Published var allCoins: [CoinModel] = []
    @Published var portofolioCoins: [CoinModel] = []
    @Published var isLoading: Bool = false
    @Published var searchText: String = ""
    @Published var sortOption: SortOption = .holdings
    
    private let coinDataService = CoinDataService()
    private let marketDataService = MarketDataService()
    private let portofolioDataService = PortofolioDataService()
    private var cancellables = Set<AnyCancellable>()
    
    
    enum SortOption {
        case rank,rankReversed,holdings,holdingsReversed, price, priceReverse
    }
    
    init(){
        addSubscribers()
    }
    
    func addSubscribers(){
        
        // updates all coins
        $searchText
            .combineLatest(coinDataService.$allCoins, $sortOption)
        // when i type quickly it won't keep updating untill the search text is not changed for 0.5 seconds
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .map (filterAndSortCoins)
            .sink { [weak self] (returnedCoins) in
                self?.allCoins = returnedCoins
            }
            .store(in: &cancellables)
        
        // updates portofolio coins
        $allCoins.combineLatest(portofolioDataService.$savedEntities)
            .map(mapAllCoinsToPortofolioCoins)
            .sink{ [weak self] (returnedCoins) in
                guard let self = self else { return }
                self.portofolioCoins = self.sortPortofolioCoinsIfNeeded(coins: returnedCoins)
            }
            .store(in: &cancellables)
        
        // updates market data
        marketDataService.$marketData
            .combineLatest($portofolioCoins)
            .map(mapGlobalMarketData)
            .sink{ [weak self] (returnedStats) in
                self?.statistics = returnedStats
                self?.isLoading = false
            }
            .store(in: &cancellables)
        
        
    }
    
    func updatePortofolio(coin:CoinModel, amount: Double){
        portofolioDataService.updatePortofolio(coin: coin, amount: amount)
    }
    
    private func mapAllCoinsToPortofolioCoins(allCoins: [CoinModel], portofolioEntities: [PortofolioEntity]) -> [CoinModel]{
        allCoins.compactMap { (coin) -> CoinModel? in
            guard let entity = portofolioEntities.first(where: { $0.coinID == coin.id}) else{
                return nil
            }
            return coin.updateHoldings(amount: entity.amount)
        }
    }
    
    func reloadData(){
        isLoading = true
        coinDataService.getCoins()
        marketDataService.getData()
        HapticManager.notification(type: .success)
    }
    
    private func filterAndSortCoins(text: String, coins: [CoinModel], sort: SortOption) -> [CoinModel] {
        var updatedCoins = filterCoins(text: text, coins: coins)
        sortCoins(sort: sort, coins: &updatedCoins)
        return updatedCoins
    }
    
    
    private func sortCoins(sort: SortOption, coins: inout [CoinModel]) {
        switch sort{
        case .rank,.holdings:
             coins.sort(by: {$0.rank < $1.rank })
        case .rankReversed,.holdingsReversed:
             coins.sort(by: {$0.rank > $1.rank })
        case .price:
             coins.sort(by: {$0.currentPrice > $1.currentPrice })
        case .priceReverse:
             coins.sort(by: {$0.currentPrice < $1.currentPrice })
        }
    }
    
    private func sortPortofolioCoinsIfNeeded(coins: [CoinModel] ) -> [CoinModel] {
        switch sortOption {
        case .holdings:
            return coins.sorted(by: { $0.currentHoldingsValue > $1.currentHoldingsValue})
        case .holdingsReversed:
            return coins.sorted(by: { $0.currentHoldingsValue < $1.currentHoldingsValue})
        default:
            return coins
        }
    }
    
    private func filterCoins(text: String, coins: [CoinModel]) -> [CoinModel] {
        guard !text.isEmpty else {
            return coins
        }
        
        let lowercasedText = text.lowercased()
        
        return coins.filter { coin in
            return coin.name.lowercased().contains(lowercasedText) ||
            coin.symbol.lowercased().contains(lowercasedText) ||
            coin.id.lowercased().contains(lowercasedText)
        }
    }
    
    private func mapGlobalMarketData(marketDataModel: MarketDataModel?,portofolioCoins: [CoinModel]) -> [StatisticModel]{
        var stats: [StatisticModel] = []
        
        guard let data = marketDataModel else {
            return stats
        }
       
        let marketCap = StatisticModel(title: "Market Cap", value: data.marketCap, percentageChange: data.marketCapChangePercentage24HUsd)
        
        let volume = StatisticModel(title: "24h Volume", value: data.volume)
        
        let btcDominance = StatisticModel(title: "BTC Dominance", value: data.btcDominance)
        
        let portofolioValue = portofolioCoins.map({ $0.currentHoldingsValue})
            .reduce(0, +)
        
        let previousValue = portofolioCoins.map { (coin) -> Double in
            let currentValue = coin.currentHoldingsValue
            let percentChange = (coin.priceChangePercentage24H ?? 0) / 100
            let previousValue = currentValue / ( 1 + percentChange )
            return previousValue
        }.reduce(0, +)
        
        let precentageChange = ((portofolioValue - previousValue) / previousValue) * 100
        
        let portofolio = StatisticModel(title: "Portofolio Value", value: portofolioValue.asCurrencyWith2Decimals(),percentageChange: precentageChange)
        
        stats.append(contentsOf: [
            marketCap,
            volume,
            btcDominance,
            portofolio
        ])
        return stats
    }
}
