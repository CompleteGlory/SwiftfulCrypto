//
//  CoinDataService.swift
//  SwiftfulCrypto
//
//  Created by Magd on 24/10/2026.
//

import Foundation
import Combine

class CoinDataService {

    // Holds the most recently fetched coins. @Published notifies any subscriber (e.g. a
    // view model) every time this array is reassigned.
    @Published var allCoins: [CoinModel] = []

    // Keeps a strong reference to the active network subscription. Without holding onto it,
    // Combine would deallocate (and cancel) the subscription as soon as getCoins() returns.
    var coinSubscription: AnyCancellable?

    init() {
        // Kick off the network request as soon as the service is created, unless we're
        // running inside an Xcode Previews canvas: the canvas can tear the preview process
        // down mid-request, and cancelling this pipeline while it's in flight crashes it.
        guard !ProcessInfo.isPreview else { return }
        getCoins()
    }

    func getCoins() {

        // Build the CoinGecko "markets" endpoint URL with the query parameters this screen
        // needs: USD pricing, sorted by market cap, 250 results, page 1, with 7-day sparkline
        // data and 24h change included. Bail out if the string somehow isn't a valid URL.
        guard let url = URL(string: "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=250&page=1&sparkline=true&price_change_percentage=24h") else { return }

        // Wrap the URL in a mutable request so a custom header can be attached to it.
        var request = URLRequest(url: url)

        // Read the CoinGecko API key out of Info.plist (which resolves $(COINGECKO_API_KEY)
        // from Config.xcconfig at build time) and, if present, attach it as the auth header
        // CoinGecko's demo-tier API expects.
        if let apiKey = Bundle.main.object(forInfoDictionaryKey: "CoinGeckoAPIKey") as? String, !apiKey.isEmpty {
            request.setValue(apiKey, forHTTPHeaderField: "x-cg-demo-api-key")
        }

        // Fire the request through the shared networking helper. Pass `request` (not `url`)
        // so the API key header set above actually gets sent. Store the returned
        // subscription so it isn't deallocated — and cancelled — before it completes.
        coinSubscription = NetworkingManager.download(request: request)

            // Decode the raw JSON response data into an array of CoinModel. CoinModel's
            // Codable conformance and CodingKeys describe how the JSON fields map to it.
            .decode(type: [CoinModel].self, decoder: JSONDecoder())

            // Subscribe to the publisher: receiveCompletion handles success/failure via the
            // shared handler, receiveValue runs once the decoded array arrives.
            .sink(receiveCompletion: NetworkingManager.handleCompletion, receiveValue: { [weak self] (returnedCoins) in

                // Publish the decoded coins so subscribers (e.g. HomeViewModel) update.
                self?.allCoins = returnedCoins

                // The request is done — cancel the subscription since there's nothing
                // left to wait for, freeing it up.
                self?.coinSubscription?.cancel()
            })
    }
}
