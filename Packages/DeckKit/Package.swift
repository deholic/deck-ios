// swift-tools-version: 5.10
import PackageDescription

let package = Package(
  name: "DeckKit",
  platforms: [.iOS(.v18)],
  products: [
    .library(
      name: "DeckKit",
      targets: [
        "DeckAccounts",
        "DeckCompose",
        "DeckTimeline",
        "DeckSettings",
        "DeckServices"
      ]
    )
  ],
  targets: [
    .target(
      name: "DeckServices"
    ),
    .target(
      name: "DeckAccounts",
      dependencies: ["DeckServices"]
    ),
    .target(
      name: "DeckCompose",
      dependencies: ["DeckServices"]
    ),
    .target(
      name: "DeckTimeline",
      dependencies: ["DeckServices"]
    ),
    .target(
      name: "DeckSettings",
      dependencies: ["DeckServices"]
    )
  ]
)
