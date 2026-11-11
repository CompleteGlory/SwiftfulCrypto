//
//  CoinImageService.swift
//  SwiftfulCrypto
//
//  Created by Magd on 25/10/2026.
//

import Foundation
import SwiftUI
import Combine

class CoinImageService {
    
    @Published var image: UIImage? = nil
    
    private var imageSubscription: AnyCancellable?
    private let coin: CoinModel
    private let fileManager = LocalFileManager.instance
    private let folderName = "coin_images"
    private let imageName: String
    init (coin: CoinModel) {
        self.coin = coin
        self.imageName = coin.id
        getCoinImage()
    }
    
    private func getCoinImage() {
        if let savedImage = fileManager.getImage(imageName: imageName, folderName: folderName){
            image = savedImage
        } else if !ProcessInfo.isPreview {
            // Only hit the network when not running inside an Xcode Previews canvas: the
            // canvas can tear the preview process down mid-request, and cancelling this
            // pipeline while it's in flight crashes it.
            downloadCoinImage()
        }
    }
    
    private func downloadCoinImage() {
            guard let url = URL(string: coin.image ) else { return }
            
            imageSubscription = NetworkingManager.download(url: url)
                .tryMap({ (data) -> UIImage? in
                    return UIImage(data: data)
                })
                .sink(receiveCompletion: NetworkingManager.handleCompletion, receiveValue: { [weak self] (returnedImage) in
                    guard let self = self, let downloadedImage = returnedImage else { return }
                    self.image = downloadedImage
                    self.imageSubscription?.cancel()
                    self.fileManager.saveImage(image: downloadedImage, imageName: self.imageName, folderName: self.folderName)
                })
    
    }
}
