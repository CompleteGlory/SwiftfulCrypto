//
//  String.swift
//  SwiftfulCrypto
//
//  Created by Magd on 06/11/2026.
//

import Foundation

extension String {
    var removingHTMLOccurances: String {
        return self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
}
