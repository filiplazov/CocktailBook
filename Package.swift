// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CocktailBook",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "CocktailBook",
            targets: ["CocktailBook"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/combine-schedulers", from: "1.0.3")
    ],
    targets: [
        .target(
            name: "CocktailBook",
            dependencies: [
                .product(name: "CombineSchedulers", package: "combine-schedulers")
            ]
        ),
        .testTarget(
            name: "CocktailBookTests",
            dependencies: [
                "CocktailBook",
                .product(name: "CombineSchedulers", package: "combine-schedulers")
            ]
        ),
    ]
) 