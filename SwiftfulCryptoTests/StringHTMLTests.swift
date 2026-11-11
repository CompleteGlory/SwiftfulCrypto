//
//  StringHTMLTests.swift
//  SwiftfulCryptoTests
//

import Testing
@testable import SwiftfulCrypto

@MainActor
struct StringHTMLTests {

    @Test func removesSimpleTags() {
        #expect("<p>Hello <b>world</b></p>".removingHTMLOccurances == "Hello world")
    }

    @Test func removesTagsThatHaveAttributes() {
        let html = "Visit <a href=\"https://example.com\" target=\"_blank\">the site</a> today"
        #expect(html.removingHTMLOccurances == "Visit the site today")
    }

    @Test func leavesPlainTextUntouched() {
        #expect("Bitcoin is a cryptocurrency".removingHTMLOccurances == "Bitcoin is a cryptocurrency")
    }

    @Test func emptyStringStaysEmpty() {
        #expect("".removingHTMLOccurances == "")
    }
}
