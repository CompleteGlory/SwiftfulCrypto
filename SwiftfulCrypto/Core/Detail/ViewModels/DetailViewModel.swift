//
//  DetailViewModel.swift
//  SwiftfulCrypto
//
//  Created by Magd on 02/11/2026.
//

import Foundation
import Combine

class DetailViewModel : ObservableObject {
    
    @Published var overViewStatistics: [StatisticModel] = []
    @Published var additionalStatistics: [StatisticModel] = []
    @Published var coinDescription: String? = nil
    @Published var webstieUrl: String? = nil
    @Published var redditUrl: String? = nil

    @Published var coin: CoinModel
    private let coinDetailService : CoinDetailDataService
    private var cancellables = Set<AnyCancellable>();
    
    init(coin: CoinModel){
        self.coin = coin
        self.coinDetailService = CoinDetailDataService(coin: coin)
        self.addSubscribers()
    }
    
    private func addSubscribers() {
        coinDetailService.$coinDetails
            .combineLatest($coin)
            .map(mapDataToStatisctics)
            .sink{ [weak self] (returnedArrays) in
                self?.overViewStatistics = returnedArrays.overview
                self?.additionalStatistics = returnedArrays.additional
            }
            .store(in: &cancellables)
        
        coinDetailService.$coinDetails
            .sink{[weak self] (returnedCoinDetails) in
                self?.coinDescription = returnedCoinDetails?.readableDescription
                self?.webstieUrl = returnedCoinDetails?.links?.homepage?.first
                self?.redditUrl = returnedCoinDetails?.links?.subredditUrl

            }
            .store(in: &cancellables)
    }
    
    private func mapDataToStatisctics(coinDetailModel: CoinDetail?, coinModel: CoinModel) -> (overview: [StatisticModel], additional: [StatisticModel]) {
        let overViewArray = createOverviewArray(coinModel: coinModel)
        let additionalArray = createAdditionalArray(coinDetailModel: coinDetailModel, coinModel: coinModel)
         return (overViewArray,additionalArray)
    }
    
    func createOverviewArray(coinModel: CoinModel) -> [StatisticModel] {
        // OverView
         
         let price = coinModel.currentPrice.asCurrencyWith6Decimals()
         let pricePercentChange = coinModel.priceChangePercentage24H
         let priceStat = StatisticModel(title: "Current Price", value: price, percentageChange: pricePercentChange)
         
         let marketCap =  "$" + (coinModel.marketCap?.formattedWithAbbreviations() ?? "")
         let marketCapPercentChange = coinModel.marketCapChangePercentage24H
         let marketCapStat = StatisticModel(title: "Market Capitalization", value: marketCap,percentageChange: marketCapPercentChange)
         
         let rank = "\(coinModel.rank)"
         let rankStat = StatisticModel(title: "Rank", value: rank)
         
         let volume = "$" + (coinModel.totalVolume?.formattedWithAbbreviations() ?? "")
         let volumeStat = StatisticModel(title: "Volume", value: volume)
         
         let overViewArray: [StatisticModel] = [
             priceStat,marketCapStat,rankStat,volumeStat
         ]
        return overViewArray
    }
    
    func createAdditionalArray(coinDetailModel: CoinDetail? , coinModel: CoinModel) -> [StatisticModel] {
        // Additional
        let high = coinModel.high24H?.asCurrencyWith6Decimals() ?? "N/A"
        let highStat = StatisticModel(title: "24h High", value: high)
        
        let low = coinModel.low24H?.asCurrencyWith6Decimals() ?? "N/A"
        let lowStat = StatisticModel(title: "24h Low", value: low)
        
        let priceChange = coinModel.priceChange24H?.asCurrencyWith6Decimals() ?? "N/A"
        let pricePercentChange = coinModel.priceChangePercentage24H
        let priceChangeStat = StatisticModel(title: "24h Price Change", value: priceChange,percentageChange: pricePercentChange)
        let marketCapChange = "$" + (coinModel.marketCapChangePercentage24H?.formattedWithAbbreviations() ?? "")
        let marketCapPercentChange = coinModel.marketCapChangePercentage24H
        let marketCapChangeStat = StatisticModel(title: "24h Market Cap Change", value: marketCapChange,percentageChange: marketCapPercentChange)
        
        let blockTime = coinDetailModel?.blockTimeInMinutes ?? 0
        let blockTimeString = blockTime == 0 ? "N/A" : "\(blockTime)"
        let blockStat = StatisticModel(title: "Block Time", value: blockTimeString)
        
        let hashing = coinDetailModel?.hashingAlgorithm ?? "N/A"
        let hashingStat = StatisticModel(title: "Hashing Algorithm", value: hashing)
        
        let additionalArray: [StatisticModel] = [
            highStat,lowStat,priceChangeStat,marketCapChangeStat,blockStat,hashingStat
        ]
        return additionalArray
    }
}
