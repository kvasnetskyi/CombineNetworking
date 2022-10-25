// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CombineNetworking",
    platforms: [.iOS(.v13), .macOS(.v10_15), .watchOS(.v6)],
    products: [
        .library(
            name: "CombineNetworking",
            targets: ["CombineNetworking"]
        ),
    ],
    targets: [
        .target(
            name: "CombineNetworking",
            dependencies: []
        ),
        .testTarget(
            name: "CombineNetworkingTests",
            dependencies: ["CombineNetworking"]
        )
    ]
)
