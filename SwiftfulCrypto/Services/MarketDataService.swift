import Foundation
import Combine

class MarketDataService {

    // Holds the most recently fetched global market data. @Published notifies any subscriber
    // (e.g. a view model) every time this value is reassigned.
    @Published var marketData: MarketDataModel? = nil

    // Keeps a strong reference to the active network subscription. Without holding onto it,
    // Combine would deallocate (and cancel) the subscription as soon as getData() returns.
    var marketDataSubscription: AnyCancellable?

    init() {
        // Kick off the network request as soon as the service is created, unless we're
        // running inside an Xcode Previews canvas: the canvas can tear the preview process
        // down mid-request, and cancelling this pipeline while it's in flight crashes it.
        guard !ProcessInfo.isPreview else { return }
        getData()
    }

     func getData() {

        guard let url = URL(string: "https://api.coingecko.com/api/v3/global" ) else { return }

        // Wrap the URL in a mutable request so a custom header can be attached to it.
        var request = URLRequest(url: url)

        // Read the CoinGecko API key out of Info.plist (which resolves $(COINGECKO_API_KEY)
        // from Config.xcconfig at build time) and, if present, attach it as the auth header
        // CoinGecko's demo-tier API expects.
        if let apiKey = Bundle.main.object(forInfoDictionaryKey: "CoinGeckoAPIKey") as? String {
            request.setValue(apiKey, forHTTPHeaderField: "x-cg-demo-api-key")
        }

        // Fire the request through the shared networking helper. Pass `request` (not `url`)
        // so the API key header set above actually gets sent. Store the returned
        // subscription so it isn't deallocated — and cancelled — before it completes.
        marketDataSubscription = NetworkingManager.download(request: request)

            // Decode the raw JSON response data into a GlobalData wrapper. GlobalData's
            // Codable conformance and MarketDataModel's CodingKeys describe how the JSON
            // fields map to it.
            .decode(type: GlobalData.self, decoder: JSONDecoder())

            // Subscribe to the publisher: receiveCompletion handles success/failure via the
            // shared handler, receiveValue runs once the decoded data arrives.
            .sink(receiveCompletion: NetworkingManager.handleCompletion, receiveValue: { [weak self] (returnedGlobalData) in

                // Publish the decoded global market data so subscribers (e.g. HomeViewModel) update.
                self?.marketData = returnedGlobalData.data

                // The request is done — cancel the subscription since there's nothing
                // left to wait for, freeing it up.
                self?.marketDataSubscription?.cancel()
            })
    }
}
