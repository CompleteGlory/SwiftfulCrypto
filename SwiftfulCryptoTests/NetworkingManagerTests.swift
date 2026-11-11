//
//  NetworkingManagerTests.swift
//  SwiftfulCryptoTests
//

import Foundation
import Testing
@testable import SwiftfulCrypto

@MainActor
struct NetworkingManagerTests {

    private let url = URL(string: "https://api.example.com/coins")!

    private func httpResponse(status: Int) -> URLResponse {
        HTTPURLResponse(url: url, statusCode: status, httpVersion: nil, headerFields: nil)!
    }

    @Test func returnsBodyForSuccessStatusCodes() throws {
        let body = Data("ok".utf8)
        for status in [200, 201, 204, 299] {
            let output = (data: body, response: httpResponse(status: status))
            let result = try NetworkingManager.handleURLResponse(output: output, url: url)
            #expect(result == body)
        }
    }

    @Test func throwsForNonSuccessStatusCodes() {
        for status in [199, 300, 301, 400, 404, 500] {
            let output = (data: Data(), response: httpResponse(status: status))
            #expect(throws: NetworkingManager.NetworkingError.self) {
                try NetworkingManager.handleURLResponse(output: output, url: url)
            }
        }
    }

    @Test func throwsWhenResponseIsNotHTTP() {
        let nonHTTP = URLResponse(url: url, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
        let output = (data: Data(), response: nonHTTP)
        #expect(throws: NetworkingManager.NetworkingError.self) {
            try NetworkingManager.handleURLResponse(output: output, url: url)
        }
    }

    @Test func badResponseErrorMentionsTheURL() {
        let error = NetworkingManager.NetworkingError.badURLResponse(url: url)
        #expect(error.errorDescription?.contains("api.example.com") == true)
    }
}
