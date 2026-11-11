//
//  StatisticView.swift
//  SwiftfulCrypto
//
//  Created by Magd on 28/10/2026.
//

import SwiftUI

struct StatisticView: View {
    let stat:StatisticModel
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 4){
            Text(stat.title)
                .font(.caption)
                .foregroundStyle(Color.theme.secondaryText)
            Text(stat.value)
                .font(.headline)
                .foregroundStyle(Color.theme.accent)
            HStack{
                
                Image(systemName: "triangle.fill")
                    .font(.caption)
                    .rotationEffect(Angle(degrees: (stat.percentageChange ?? 0) >= 0 ? 0 : 180))
                Text(stat.percentageChange?.asPercentString() ?? "")
                    .font(.caption)
                    .bold()
            }
            .foregroundStyle( (stat.percentageChange ?? 0) >= 0 ? Color.theme.green : Color.theme.red )
            .opacity(stat.percentageChange == nil ? 0.0 : 1.0)
           
        }
    }
}

#Preview {
    StatisticView(stat: DeveloperPreview.instance.state1)
}
