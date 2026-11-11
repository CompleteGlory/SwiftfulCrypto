//
//  CoinImageViewModel.swift
//  SwiftfulCrypto
//
//  Created by Magd on 25/10/2026.
//

import Foundation
import SwiftUI
import Combine

class CoinImageViewModel: ObservableObject {
    
    @Published var image: UIImage? = nil
    @Published var isLoading: Bool = false
    
    private let coin: CoinModel
    private let dataService: CoinImageService
    private var cancellables = Set<AnyCancellable>()
    
    
    init(coin: CoinModel) {
        self.coin = coin
        self.dataService = CoinImageService(coin: coin)
        // Previews never download images (see ProcessInfo.isPreview), so there is
        // nothing to wait for there — show the placeholder instead of a spinner.
        self.isLoading = !ProcessInfo.isPreview
        addSubscribers()
    }
    
    private func addSubscribers(){
        // @Published never sends a completion, so loading has to end when an image arrives.
        dataService.$image
            .sink { [weak self] (returnedImage) in
                self?.image = returnedImage
                if returnedImage != nil {
                    self?.isLoading = false
                }
            }
            .store(in: &cancellables)

    }
}
