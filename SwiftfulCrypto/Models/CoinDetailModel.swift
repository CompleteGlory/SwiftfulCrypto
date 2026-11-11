//
//  CoinDetailModel.swift
//  SwiftfulCrypto
//
//  Created by Magd on 02/11/2026.
//

import Foundation

// Model for CoinGecko GET /api/v3/coins/{id}
//
// Only id, symbol and name are non-optional. Everything else varies by coin
// and by the query flags (market_data, tickers, ...), so it is optional and a
// missing key decodes to nil instead of failing the whole response.
//
// Explicit CodingKeys are used instead of .convertFromSnakeCase on purpose:
// that strategy also rewrites dictionary keys such as the platform names in
// `platforms` and `detailPlatforms`.

/* https://api.coingecko.com/api/v3/coins/{id}?localization=false&market_data=false&community_data=false&developer_data=false&sparkline=false&include_categories_details=false&dex_pair_format=symbol&tickers=false
*/

//
//  CoinDetailModel.swift
//  SwiftfulCrypto
//
//  Created by Magd on 02/11/2026.
//

import Foundation

// Model for CoinGecko GET /api/v3/coins/{id}
//
// Only id, symbol and name are non-optional. Everything else varies by coin
// and by the query flags (market_data, tickers, ...), so it is optional and a
// missing key decodes to nil instead of failing the whole response.
//
// Explicit CodingKeys are used instead of .convertFromSnakeCase on purpose:
// that strategy also rewrites dictionary keys such as the platform names in
// `platforms` and `detailPlatforms`.

/* https://api.coingecko.com/api/v3/coins/{id}?localization=false&market_data=false&community_data=false&developer_data=false&sparkline=false&include_categories_details=false&dex_pair_format=symbol&tickers=false
*/

struct CoinDetail: Codable, Identifiable {
    let id: String
    let symbol: String
    let name: String
    let blockTimeInMinutes: Int?
    let hashingAlgorithm: String?
    let categories: [String]?
    let previewListing: Bool?
    let description: Description?
    let links: Links?

    enum CodingKeys: String, CodingKey {
        case id, symbol, name, categories, description, links
        case blockTimeInMinutes = "block_time_in_minutes"
        case hashingAlgorithm = "hashing_algorithm"
        case previewListing = "preview_listing"
    }
    
    var readableDescription: String? {
        return description?.en?.removingHTMLOccurances
    }
}

// CoinGecko returns one key per language (en, de, es, ...); only "en" is needed here,
// and Codable ignores the rest when decoding into this struct.
struct Description: Codable {
    let en: String?
}

struct Links: Codable {
    let homepage: [String]?
    let subredditUrl: String?

    enum CodingKeys: String, CodingKey {
        case homepage
        case subredditUrl = "subreddit_url"
    }
}

extension CoinDetail {
    // Used in place of a live network fetch when running inside an Xcode Previews
    // canvas, so previews show realistic description/links content without the
    // live Combine pipeline that crashes when the canvas tears a preview down
    // mid-request. See ProcessInfo.isPreview.
    static var mock: CoinDetail {
        CoinDetail(
            id: "bitcoin",
            symbol: "btc",
            name: "Bitcoin",
            blockTimeInMinutes: 10,
            hashingAlgorithm: "SHA-256",
            categories: ["Cryptocurrency", "Layer 1 (L1)"],
            previewListing: false,
            description: Description(en: "Bitcoin is the world's first decentralized cryptocurrency, created in 2009 by the pseudonymous Satoshi Nakamoto. It enables peer-to-peer electronic cash transactions without intermediaries like banks or governments, operating on a blockchain secured by Proof of Work mining and the SHA-256 cryptographic algorithm."),
            links: Links(homepage: ["https://www.bitcoin.org"], subredditUrl: "https://www.reddit.com/r/Bitcoin/")
        )
    }
}
