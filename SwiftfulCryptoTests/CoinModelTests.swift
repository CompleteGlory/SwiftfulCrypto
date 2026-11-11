//
//  CoinModelTests.swift
//  SwiftfulCryptoTests
//

import Foundation
import Testing
@testable import SwiftfulCrypto

@MainActor
struct CoinModelTests {

    // A trimmed-down CoinGecko /coins/markets payload: only the fields the model requires,
    // plus a few optional ones so the snake_case CodingKeys are exercised.
    private let fullJSON = """
    {
      "id": "bitcoin",
      "symbol": "btc",
      "name": "Bitcoin",
      "image": "https://example.com/btc.png",
      "current_price": 40000.0,
      "market_cap_rank": 1,
      "price_change_percentage_24h": -2.5,
      "sparkline_in_7d": { "price": [1.0, 2.0, 3.0] }
    }
    """

    private let minimalJSON = """
    {
      "id": "dogecoin",
      "symbol": "doge",
      "name": "Dogecoin",
      "image": "https://example.com/doge.png",
      "current_price": 0.1
    }
    """

    private func decode(_ json: String) throws -> CoinModel {
        try JSONDecoder().decode(CoinModel.self, from: Data(json.utf8))
    }

    // MARK: Decoding

    @Test func decodesSnakeCaseKeys() throws {
        let coin = try decode(fullJSON)
        #expect(coin.id == "bitcoin")
        #expect(coin.symbol == "btc")
        #expect(coin.name == "Bitcoin")
        #expect(coin.currentPrice == 40_000)
        #expect(coin.priceChangePercentage24H == -2.5)
        #expect(coin.sparklineIn7D?.price == [1, 2, 3])
    }

    @Test func missingOptionalFieldsDecodeAsNil() throws {
        let coin = try decode(minimalJSON)
        #expect(coin.marketCap == nil)
        #expect(coin.sparklineIn7D == nil)
        #expect(coin.currentHoldings == nil)
    }

    @Test func missingRequiredFieldThrows() {
        let noPrice = """
        { "id": "x", "symbol": "x", "name": "X", "image": "https://example.com/x.png" }
        """
        #expect(throws: DecodingError.self) {
            try decode(noPrice)
        }
    }

    // MARK: Rank

    @Test func rankComesFromMarketCapRank() throws {
        #expect(try decode(fullJSON).rank == 1)
    }

    @Test func rankDefaultsToZeroWhenMissing() throws {
        #expect(try decode(minimalJSON).rank == 0)
    }

    // MARK: Holdings

    @Test func holdingsValueIsZeroWithoutHoldings() throws {
        let coin = try decode(fullJSON)
        #expect(coin.currentHoldingsValue == 0)
    }

    @Test func updateHoldingsComputesValueAtCurrentPrice() throws {
        let coin = try decode(fullJSON).updateHoldings(amount: 0.5)
        #expect(coin.currentHoldings == 0.5)
        #expect(coin.currentHoldingsValue == 20_000)
    }

    @Test func updateHoldingsKeepsOtherFieldsAndLeavesOriginalUnchanged() throws {
        let original = try decode(fullJSON)
        let updated = original.updateHoldings(amount: 2)

        #expect(updated.id == original.id)
        #expect(updated.name == original.name)
        #expect(updated.currentPrice == original.currentPrice)
        #expect(original.currentHoldings == nil)
    }
}
