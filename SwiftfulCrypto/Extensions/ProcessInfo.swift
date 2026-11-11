//
//  ProcessInfo.swift
//  SwiftfulCrypto
//

import Foundation

extension ProcessInfo {
    // Xcode sets this env var to "1" for every process it launches to render a
    // #Preview. Services gate their automatic network calls on this so the
    // Previews canvas never has a live Combine pipeline in flight for it to
    // tear down mid-request, which otherwise crashes the preview process.
    static var isPreview: Bool {
        processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}
