//
//  HomeStatsView.swift
//  SwiftfulCrypto
//
//  Created by Magd on 28/10/2026.
//

import SwiftUI

struct HomeStatsView: View {
    @EnvironmentObject private var vm: HomeViewModel
    
    @Binding var showPortofolio: Bool
    
    var body: some View {
        HStack{
            ForEach(vm.statistics){ stat in
                StatisticView(stat: stat)
                    .containerRelativeFrame(.horizontal) { length, axis in
                        length / 3
                    }
            }
        }
        .containerRelativeFrame(.horizontal, alignment: showPortofolio ? .trailing : .leading)
    }
}
 
#Preview {
    HomeStatsView(showPortofolio: .constant(false))
        .environmentObject(DeveloperPreview.instance.homeVM)
}
