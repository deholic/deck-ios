// swift-tools-version: 6.0
import PackageDescription

let package = Package(
  name: "DeckKit",
  platforms: [.iOS(.v18)],
  products: [
    .library(
      name: "DeckKit",
      targets: [
        "DeckDomain",
        "DeckSharedUI",
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
      name: "DeckDomain"
    ),
    .target(
      name: "DeckSharedUI"
    ),
    .target(
      name: "DeckServices",
      dependencies: ["DeckDomain"]
    ),
    .target(
      name: "DeckAccounts",
      dependencies: ["DeckServices"]
    ),
    .target(
      name: "DeckCompose",
      dependencies: ["DeckServices", "DeckDomain"]
    ),
    .target(
      name: "DeckTimeline",
      dependencies: ["DeckServices", "DeckDomain", "DeckSharedUI"]
    ),
    .target(
      name: "DeckSettings",
      dependencies: ["DeckServices", "DeckDomain"]
    ),
    .testTarget(
      name: "DeckDomainTests",
      dependencies: ["DeckDomain"]
    )
  ]
)
