//
//  NetworkingManager.swift
//  SwiftfulCrypto
//
//  Created by Magd on 25/10/2026.
//

import Foundation
import Combine

class NetworkingManager {

    // MARK: - Errors

    // Custom error type so failures carry a readable, app-specific message instead of a
    // generic URLError.
    enum NetworkingError: LocalizedError {

        // The response wasn't HTTP, or its status code fell outside 200-299.
        case badURLResponse(url: URL)

        // Reserved for any other failure that doesn't have a more specific case.
        case unknown

        // LocalizedError reads this to produce the string printed/shown for each case.
        var errorDescription: String? {
            switch self {
            case .badURLResponse(url: let url): return "[🔥] Bad Response From URL \(url) !"
            case .unknown: return "[⚠️] Unknown Error occured !"
            }
        }
    }

    // MARK: - Download

    // Performs a network request for the given URL and hands back the raw response body as
    // a Combine publisher.
    static func download(url: URL) -> AnyPublisher<Data, Error> {

        // dataTaskPublisher creates a publisher that will perform the request the moment
        // something subscribes to it, and emits (data, response) once it completes.
        return URLSession.shared.dataTaskPublisher(for: url)

            // Runs the request itself (connecting, waiting on the server) on a background
            // queue, so the network call never blocks the calling thread.
            .subscribe(on: DispatchQueue.global(qos: .default))

            // tryMap behaves like map, but is allowed to throw. The actual validation is
            // delegated to handleURLResponse below so this chain stays readable; any
            // thrown error becomes a .failure further down the chain instead of crashing.
            .tryMap({ try handleURLResponse(output: $0, url: url) })

            // Switches delivery of everything downstream onto the main thread, since the
            // subscriber is typically updating UI-driving state.
            .receive(on: DispatchQueue.main)

            // Hides the concrete (and very long) publisher type behind AnyPublisher, so
            // callers only need to know "this returns Data or fails with Error".
            .eraseToAnyPublisher()
    }

    // Same as download(url:) above, but takes a full URLRequest instead of a bare URL.
    // Callers need this overload whenever they've attached custom headers (e.g. an API key)
    // to the request - passing just the URL would silently drop those headers.
    static func download(request: URLRequest) -> AnyPublisher<Data, Error> {

        // dataTaskPublisher(for:) also accepts a URLRequest directly, so the request
        // (including any headers set on it) is sent exactly as the caller configured it.
        return URLSession.shared.dataTaskPublisher(for: request)

            // Runs the request itself (connecting, waiting on the server) on a background
            // queue, so the network call never blocks the calling thread.
            .subscribe(on: DispatchQueue.global(qos: .default))

            // Reuse the same validation as the URL-based overload. request.url is force-
            // unwrapped here because URLRequest always carries the URL it was created with.
            .tryMap({ try handleURLResponse(output: $0, url: request.url!) })

            // Switches delivery of everything downstream onto the main thread, since the
            // subscriber is typically updating UI-driving state.
            .receive(on: DispatchQueue.main)

            // Hides the concrete (and very long) publisher type behind AnyPublisher, so
            // callers only need to know "this returns Data or fails with Error".
            .eraseToAnyPublisher()
    }

    // Validates a single dataTaskPublisher output and extracts its body data, or throws.
    // Pulled out of `download` so the Combine chain above isn't cluttered with a multi-line
    // guard block.
    static func handleURLResponse(output: URLSession.DataTaskPublisher.Output, url: URL) throws -> Data {

        // output.response is typed as the generic URLResponse; only its HTTP-specific
        // subclass exposes statusCode, so we try to downcast to that first.
        guard let response = output.response as? HTTPURLResponse,

              // The downcast must succeed AND the status code must fall in 200-299
              // for the server to be considered to have returned success.
              response.statusCode >= 200 && response.statusCode < 300 else {

            // Either check failed: throw our own error type, with the offending URL
            // attached, instead of a generic URLError.
            throw NetworkingError.badURLResponse(url: url)
        }

        // Success: discard the response object and keep only the response body.
        return output.data
    }

    // MARK: - Completion Handling

    // Shared completion handler passed to `sink(receiveCompletion:)` calls across the app:
    // does nothing when the publisher finishes normally, logs the error when it fails.
    nonisolated static func handleCompletion(completion: Subscribers.Completion<Error>) {
        switch completion {

        // The publisher finished without error — nothing to do.
        case .finished:
            break

        // The publisher failed — print the error so it's visible during development.
        case .failure(let error):
            print(error.localizedDescription)
        }
    }

}
