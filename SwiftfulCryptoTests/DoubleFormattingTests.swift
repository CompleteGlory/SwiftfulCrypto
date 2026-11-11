//
//  DoubleFormattingTests.swift
//  SwiftfulCryptoTests
//
//  Note: asCurrencyWith2Decimals / asCurrencyWith6Decimals are intentionally not asserted
//  here. Their formatters follow Locale.current, so exact output varies by device region.
//

import Testing
@testable import SwiftfulCrypto

@MainActor
struct DoubleFormattingTests {

    // MARK: asNumberString

    @Test func numberStringRoundsToTwoDecimals() {
        #expect(1.2345.asNumberString() == "1.23")
        #expect(12.0.asNumberString() == "12.00")
        #expect(0.0.asNumberString() == "0.00")
        #expect((-3.456).asNumberString() == "-3.46")
    }

    // MARK: asPercentString

    @Test func percentStringAppendsPercentSign() {
        #expect(1.2345.asPercentString() == "1.23%")
        #expect(0.0.asPercentString() == "0.00%")
        #expect((-3.456).asPercentString() == "-3.46%")
    }

    // MARK: formattedWithAbbreviations

    @Test func smallNumbersAreNotAbbreviated() {
        #expect(0.0.formattedWithAbbreviations() == "0.00")
        #expect(12.0.formattedWithAbbreviations() == "12.00")
        #expect(999.0.formattedWithAbbreviations() == "999.00")
    }

    @Test func thousandsUseK() {
        #expect(1_000.0.formattedWithAbbreviations() == "1.00K")
        #expect(1_234.0.formattedWithAbbreviations() == "1.23K")
        #expect(1_500.0.formattedWithAbbreviations() == "1.50K")
    }

    @Test func millionsUseM() {
        #expect(1_000_000.0.formattedWithAbbreviations() == "1.00M")
        #expect(2_500_000.0.formattedWithAbbreviations() == "2.50M")
    }

    @Test func billionsUseBn() {
        #expect(7_250_000_000.0.formattedWithAbbreviations() == "7.25Bn")
    }

    @Test func trillionsUseTr() {
        #expect(3_000_000_000_000.0.formattedWithAbbreviations() == "3.00Tr")
    }

    @Test func negativeLargeNumbersKeepTheirSign() {
        #expect((-1_500.0).formattedWithAbbreviations() == "-1.50K")
    }

    @Test func negativeSmallNumbersAreNotAbbreviated() {
        #expect((-5.0).formattedWithAbbreviations() == "-5.00")
    }
}
