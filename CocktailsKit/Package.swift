// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CocktailsKit",
    platforms: [
        .iOS(.v18),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "CocktailsKit",
            targets: ["CocktailsKit"]
        ),
    ],
    dependencies: [
        // No external dependencies needed for this package
    ],
    targets: [
        .target(
            name: "CocktailsKit",
            dependencies: [],
            resources: [
                .process("sample.json")
            ]
        ),
        .testTarget(
            name: "CocktailsKitTests",
            dependencies: ["CocktailsKit"]
        ),
    ]
) 