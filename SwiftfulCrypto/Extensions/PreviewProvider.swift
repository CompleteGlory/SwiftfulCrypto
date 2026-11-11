//
//  PreviewProvider.swift
//  SwiftfulCrypto
//
//  Created by Magd on 24/10/2026.
//

import Foundation
import SwiftUI

extension PreviewProvider {
    
    static  var dev: DeveloperPreview {
        return DeveloperPreview.instance
    }
    
}

class DeveloperPreview {
    
    static let instance = DeveloperPreview()
    private init(){ }
    
    let homeVM = HomeViewModel()
    
    let state1 = StatisticModel(title: "Market Cap", value: "12.5Bn", percentageChange: 25.34)
    
    let state2 = StatisticModel(title: "Total Volume", value: "1.23Tn")

    
    let coin = CoinModel(
        id: "bitcoin",
        symbol: "btc",
        name: "Bitcoin",
        image: "https://coin-images.coingecko.com/coins/images/1/large/bitcoin.png?1696501400",
        currentPrice: 80498,
        marketCap: 1618227113070,
        marketCapRank: 1,
        fullyDilutedValuation: 1618235726369,
        totalVolume: 22475464433,
        high24H: 81939,
        low24H: 80455,
        priceChange24H: -1129.9673898960173,
        priceChangePercentage24H: -1.37919,
        marketCapChange24H: -22678190420.918945,
        marketCapChangePercentage24H: -1.38205,
        circulatingSupply: 20102671.0,
        totalSupply: 20102778.0,
        maxSupply: 21000000.0,
        ath: 126080,
        athChangePercentage: -36.15311,
        athDate: "2025-10-06T10:57:42.000Z",
        atl: 67.81,
        atlChangePercentage: 118612.99192,
        atlDate: "2013-07-05T16:00:00.000Z",
        lastUpdated: "2026-10-24T09:23:56.000Z",
        sparklineIn7D: SparklineIn7D(price: [
                    81045.84776489827,
                   81001.73089268175,
                   80898.20817826076
        ]),
        priceChangePercentage24HInCurrency: -1.37919,
        currentHoldings: 1
    )
    
}


