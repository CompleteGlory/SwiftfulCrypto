//
//  ChartView.swift
//  SwiftfulCrypto
//
//  Created by Magd on 02/11/2026.
//

import SwiftUI

struct ChartView: View {
    private let data: [Double]
    private let maxY: Double
    private let minY: Double
    private let lineColor: Color
    private let startingDate: Date
    private let endingDate: Date
    @State private var percentage: CGFloat = 0
    
    init(coin: CoinModel) {
        self.data = coin.sparklineIn7D?.price ?? []
        maxY = data.max() ?? 0
        minY = data.min() ?? 0
        let priceChange = (data.last ?? 0) - (data.first ?? 0)
        lineColor = priceChange > 0 ? Color.theme.green : Color.theme.red
        endingDate = Date(coinGeckoString: coin.lastUpdated ?? "")
        startingDate = endingDate.addingTimeInterval(-7*24*60*60)
    }
    var body: some View {
        VStack{
            chartView
                .frame(height: 200)
                .background(chartBackground)
                .overlay(chartYAxis.padding(.horizontal,4),
                         alignment: .leading)
           chartDateLabel.padding(.horizontal,4)
        }
        .font(.caption)
        .foregroundStyle(Color.theme.secondaryText)
        .onAppear{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                withAnimation(.linear(duration: 6.0)) {
                    percentage = 1.0
                }
            }
        }
    }
}

#Preview {
    ChartView(coin: DeveloperPreview.instance.coin)
}

extension ChartView {
        private var chartView : some View {
            GeometryReader { geometry in
                Path { path in
                    for index in data.indices {
                        let xPosition = geometry.size.width / CGFloat(max(data.count - 1, 1)) * CGFloat(index)
                        
                        let yAxis = maxY - minY
                        
                        // A flat sparkline (e.g. a stablecoin whose price never moves over the
                        // window) makes maxY == minY, which would divide by zero and feed NaN
                        // into CGPoint below, crashing the Path. Fall back to a flat midline.
                        let yPosition = yAxis == 0 ?
                            geometry.size.height / 2 :
                            (1 - CGFloat((data[index] - minY) / yAxis)) * geometry.size.height
                        
                        if index == 0 {
                            path.move(to: CGPoint(x:xPosition,y:yPosition))
                        }
                        path.addLine(to: CGPoint(x:xPosition,y:yPosition))
                    }
                }
                .trimmedPath(from: 0, to: percentage)
                .stroke(lineColor , style: StrokeStyle(lineWidth: 2,lineCap: .round,lineJoin: .round))
                .shadow(color: lineColor , radius: 10,x:0,y:10)
                .shadow(color: lineColor.opacity(0.5) , radius: 10,x:0,y:20)
                .shadow(color: lineColor.opacity(0.2) , radius: 10,x:0,y:30)
                .shadow(color: lineColor.opacity(0.1) , radius: 10,x:0,y:40)
            }
        }
    
    private var chartYAxis : some View {
        VStack{
        Text(maxY.formattedWithAbbreviations())
        Spacer()
        Text(((maxY + minY) / 2).formattedWithAbbreviations())
        Spacer()
        Text(minY.formattedWithAbbreviations())
        }
    }

    private var chartBackground : some View {
        VStack{
            Divider()
            Spacer()
            Divider()
            Spacer()
            Divider()
            }
        }
    
    private var chartDateLabel : some View {
        HStack{
            Text(startingDate.asShortDateString())
            Spacer()
            Text(endingDate.asShortDateString() )
            }
        }
    }




