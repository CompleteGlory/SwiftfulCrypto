//
//  HomeView.swift
//  SwiftfulCrypto
//
//  Created by Magd on 23/10/2026.
//

import SwiftUI

struct HomeView: View {
    
    @State private var showPortofolio: Bool = false // animate right
    @State private var showPortofolioView: Bool = false // animate sheet
    @State private var selecedCoin: CoinModel? = nil
    @State private var showDetailView: Bool = false

    @EnvironmentObject private var vm: HomeViewModel
    
    var body: some View {
        ZStack{
            // Background layer
            Color.theme.backGround
                .ignoresSafeArea()
            // Content layer
            VStack{
                homeHeader
                HomeStatsView(showPortofolio: $showPortofolio)
                SearchBarView(searchText: $vm.searchText )
                columnTitles
                .font(.caption)
                .foregroundStyle(Color.theme.secondaryText)
                .padding(.horizontal)
                Group {
                    if !showPortofolio{
                        allCoinsList
                        .transition(.move(edge:.leading))
                    } else {
                        portofolioCoinsList
                            .transition(.move(edge: .trailing))
                    }
                }
               
                Spacer(minLength: 0)
            }
        }
        .sheet(isPresented: $showPortofolioView) {
            PortofolioView()
                .environmentObject(vm)
        }
        .navigationDestination(isPresented: $showDetailView) {
            DetailLoadingView(coin: $selecedCoin)
        }
    }
}

#Preview {
    NavigationStack{
        HomeView()
            .navigationBarBackButtonHidden(true)
    }.environmentObject(DeveloperPreview.instance.homeVM)
}

extension HomeView {
    private var homeHeader: some View {
        HStack{
            CircleButtonView(iconName: showPortofolio ? "plus" :"info" )
                .animation(.none, value: showPortofolio)
                .onTapGesture{
                    showPortofolioView.toggle()
                }
                .background(
                    CircleButtonAnimationView(animate: $showPortofolio)
                )
            
            Spacer()
            
            Text(showPortofolio ? "Portofolio" : "Live Prices")
                .font(.headline)
                .fontWeight(.heavy)
                .foregroundStyle(Color.theme.accent)
                .animation(.none, value: showPortofolio)
            
            Spacer()
            
            CircleButtonView(iconName: "chevron.right")
                .rotationEffect(Angle(degrees: showPortofolio ? 180 : 0))
                .onTapGesture {
                    withAnimation(.spring()){
                        showPortofolio.toggle()
                }
            }
        }
        .padding(.horizontal)
    }
    
    private var allCoinsList: some View{
        List{
            ForEach(vm.allCoins){ coin in
                CoinRowView(coin: coin, showHoldingsColumn: false)
                    .listRowInsets(.init(top:10 , leading: 0,bottom: 10,trailing: 10))
                    .onTapGesture {
                        segue(coin: coin)
                    }
            }
        }
        .listStyle(PlainListStyle())
        // Lets the user pull the list down to trigger the same reload as the goforward
        // button. `refreshable` wants an async closure so it knows when to stop spinning;
        // vm.reloadData() itself is fire-and-forget (it just kicks off Combine publishers
        // and returns immediately), so the pull-to-refresh spinner dismisses right away
        // while the goforward icon keeps spinning via vm.isLoading until the data lands.
        .refreshable {
            vm.reloadData()
        }
    }

    
    
    
    private var portofolioCoinsList: some View{
        List{
            ForEach(vm.portofolioCoins){ coin in
                CoinRowView(coin: coin, showHoldingsColumn: true)
                    .listRowInsets(.init(top:10 , leading: 0,bottom: 10,trailing: 10))
                    .onTapGesture {
                        segue(coin: coin)
                    }
            }
        }
        .listStyle(PlainListStyle())
        // Same pull-to-refresh behavior as allCoinsList, reusing the exact same
        // reloadData() call the goforward button uses.
        .refreshable {
            vm.reloadData()
        }
    }
    
    private func segue(coin: CoinModel){
        selecedCoin = coin
        showDetailView.toggle()
    }
    
    private var columnTitles: some View{
        HStack{
            HStack(spacing:4){
                Text("Coin")
                Image(systemName: "chevron.down")
                    .opacity((vm.sortOption == .rank || vm.sortOption == .rankReversed) ? 1.0 : 0.0)
                    .rotationEffect(Angle(degrees: vm.sortOption == .rank ? 0 : 180))
            }
            .onTapGesture {
                withAnimation(.default){
                    vm.sortOption = vm.sortOption == .rank ? .rankReversed : .rank
                }
            }
            
            Spacer()
            
            if showPortofolio {
                HStack(spacing:4){
                    Text("Holdings")
                    Image(systemName: "chevron.down")
                        .opacity((vm.sortOption == .holdings || vm.sortOption == .holdingsReversed) ? 1.0 : 0.0)
                        .rotationEffect(Angle(degrees: vm.sortOption == .holdings ? 0 : 180))
                }
                .onTapGesture {
                    withAnimation(.default){
                        vm.sortOption = vm.sortOption == .holdings ? .holdingsReversed : .holdings
                    }
                }
            }
            
            HStack(spacing:4){
                Text("Price")
                Image(systemName: "chevron.down")
                    .opacity((vm.sortOption == .price || vm.sortOption == .priceReverse) ? 1.0 : 0.0)
                    .rotationEffect(Angle(degrees: vm.sortOption == .price ? 0 : 180))
            }
            .containerRelativeFrame(.horizontal, alignment: .trailing) { length, axis in
                    length / 3.5
                }
            .onTapGesture {
                withAnimation(.default){
                    vm.sortOption = vm.sortOption == .price ? .priceReverse : .price
                }
            }
            
            Button(action: {
                withAnimation(.linear(duration: 2)) {
                    vm.reloadData()
                }
            },label: {
                Image(systemName: "goforward")
            })
            .rotationEffect(Angle(degrees: vm.isLoading ? 360 : 0), anchor: .center)
        }
    }
}
