# SwiftfulCrypto

A SwiftUI crypto tracker for iOS. It shows live prices for the top 250 coins from the [CoinGecko API](https://www.coingecko.com/en/api), lets you search and sort them, keeps a portfolio on-device with Core Data, and has a detail page with a 7-day price chart for each coin.

> **Credit.** I built this by following Nick Sarno's *Crypto Tracker* SwiftUI course from [Swiftful Thinking](https://www.youtube.com/@SwiftfulThinking). The overall architecture and feature set come from that course. What I changed or added on top is listed under [What I changed](#what-i-changed).

## Features

- **Live prices**: top 250 coins by market cap, with 24h change and a 7-day sparkline.
- **Search and sort**: debounced search (0.5 s) across name, symbol and id; sort by rank, holdings or price.
- **Portfolio**: add the coins you hold and how much of each; holdings are saved with Core Data and valued at current prices.
- **Market header**: market cap, 24h volume, BTC dominance and your portfolio value with 24h change.
- **Coin detail**: animated 7-day chart, overview and additional statistics, expandable description, website and Reddit links.
- **Pull to refresh**, haptic feedback on reload, and an on-disk cache for coin logos.

## Tech

SwiftUI, MVVM, Combine, Core Data, `URLSession`, Swift Testing, and the CoinGecko REST API.

## Architecture

```
SwiftfulCrypto/
├── SwiftfulCryptoApp.swift   App entry point; injects HomeViewModel
├── Core/
│   ├── Home/                 Coin list, portfolio list, header stats, add-holdings sheet
│   ├── Detail/               Coin detail screen and 7-day chart
│   ├── Components/           Reusable views: search bar, coin logo, buttons, stat tile
│   └── Launch/               Launch screen
├── Models/                   CoinModel, MarketDataModel, CoinDetailModel, StatisticModel, Core Data model
├── Services/                 Network and persistence (CoinData, MarketData, CoinDetail, CoinImage, Portofolio)
├── Utilities/                NetworkingManager, LocalFileManager (image cache), HapticManager
└── Extensions/               Double, String, Date and Color helpers
```

**Data flow.** Services own the I/O and expose `@Published` properties. View models combine those streams with Combine (`combineLatest`, `debounce`, `map`) into view-ready state, and views observe the view models through `@StateObject` and `@EnvironmentObject`. For example, `HomeViewModel` merges the coin list, the search text and the sort option into the visible list, and joins coins with the saved Core Data entities to build the portfolio.

## Getting started

1. Clone the repo and open `SwiftfulCrypto.xcodeproj` in Xcode. The deployment target is iOS 27.0, so you need an Xcode that ships the iOS 27 SDK.
2. *(Optional)* Add your own CoinGecko demo key. Copy `Secrets.xcconfig.template` to `Secrets.xcconfig` and paste your key in. `Secrets.xcconfig` is git-ignored, so the key never gets committed.
3. Build and run on a simulator.

How the key flows: `Secrets.xcconfig` → `Config.xcconfig` → `Info.plist` (`CoinGeckoAPIKey`) → `x-cg-demo-api-key` request header. Without a key the app calls the public tier, which has a lower rate limit.

## Tests

Press ⌘U in Xcode. The unit tests cover the number formatters, HTML stripping, `CoinModel` decoding and holdings maths, and network response validation.

## What I changed

- **API key handling.** CoinGecko now wants an API key, so I added a build-time injection path (xcconfig → Info.plist → request header) that keeps the key out of git.
- **Current APIs.** `NavigationStack` with `navigationDestination(isPresented:)` and `refreshable` pull-to-refresh.
- **Current toolchain.** Builds with default main-actor isolation and member import visibility enabled, with the isolation fixes that needs.
- **Unit tests** for the pure logic (formatters, decoding, response validation).
- **Repo hygiene.** Proper `.gitignore`, secrets kept out of history, this README.

## Ideas for next

- Replace the Combine networking with `async`/`await`
- Price alerts with local notifications
- Home-screen widget for portfolio value
- iPad layout

## About

I'm a Flutter developer (Dart, NestJS, Firebase) moving into native iOS, and building small SwiftUI apps is how I'm learning the platform. Feedback is welcome.
