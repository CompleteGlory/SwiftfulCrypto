//
//  CoinRowView.swift
//  SwiftfulCrypto
//
//  Created by Magd on 24/10/2026.
//

import SwiftUI

struct CoinRowView: View {
    let coin: CoinModel
    let showHoldingsColumn: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            leftColumn
            Spacer()
            if showHoldingsColumn {
                CentetColumn
            }
           rightColumn
        }
        .font(.subheadline)
        .background(Color.theme.backGround.opacity(0.001))
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    VStack(spacing: 0) {
        CoinRowView(coin: DeveloperPreview.instance.coin, showHoldingsColumn: true)
            .padding()
            .background(Color.theme.backGround)
            .preferredColorScheme(.light)
    }
}


extension CoinRowView {
    
    private var leftColumn: some View{
        HStack(spacing: 0){
            Text("\(coin.rank)")
                .font(.caption)
                .foregroundStyle(Color.theme.secondaryText)
                .frame(minWidth: 30)
            
            CoinImageView(coin: coin)
                .frame(width: 30,height: 30)
            
            Text(coin.symbol.uppercased())
                .font(.headline)
                .padding(.leading,6)
            .foregroundStyle(Color.theme.accent)
        }
    }
    
    private var CentetColumn: some View{
        VStack(alignment: .trailing){
            
            Text(coin.currentHoldingsValue.asCurrencyWith2Decimals())
                .bold()
            
            Text((coin.currentHoldings ?? 0).asNumberString())
            
        }
        .foregroundStyle(Color.theme.accent)
    }
    
    private var rightColumn : some View {
        VStack(alignment: .trailing){
            
            Text(coin.currentPrice.asCurrencyWith6Decimals())
                .bold()
                .foregroundStyle(Color.theme.accent)
            
            Text(coin.priceChangePercentage24H? .asPercentString() ?? "")
                .foregroundStyle( (coin.priceChange24H ?? 0) >= 0 ? Color.theme.green : Color.theme.red )
        }
        .containerRelativeFrame(.horizontal, alignment: .trailing) { length, axis in
            length / 3.5
        }
    }
}
