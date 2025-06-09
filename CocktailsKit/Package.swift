// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CocktailsKit",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "CocktailsKit",
            targets: ["CocktailsKit"]
        ),
        .library(
            name: "CocktailsModels",
            targets: ["CocktailsModels"]
        ),
    ],
    dependencies: [
        // No external dependencies needed for this package
    ],
    targets: [
        .target(
            name: "CocktailsModels",
            dependencies: []
        ),
        .target(
            name: "CocktailsKit",
            dependencies: ["CocktailsModels"],
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