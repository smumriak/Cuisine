// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Cuisine",
    products: [
        .library(name: "Cuisine", targets: ["Cuisine"]),
        .library(name: "CuisineArgumentParser", targets: ["CuisineArgumentParser"]),
    ],
    dependencies: [
        .package(url: "https://github.com/smumriak/ShellOut.git", branch: "master"),
        .package(url: "https://github.com/apple/swift-system", from: "1.0.0"),
        .package(url: "https://github.com/philipturner/swift-reflection-mirror", branch: "main"),
        .package(url: "https://github.com/smumriak/AppKid", branch: "main"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
    ],
    targets: [
        .executableTarget(
            name: "CuisineDemo",
            dependencies: [
                "Cuisine",
                "CuisineArgumentParser",
            ]),
        .target(
            name: "Cuisine",
            dependencies: [
                .product(name: "ShellOut", package: "ShellOut"),
                .product(name: "SystemPackage", package: "swift-system"),
                .product(name: "ReflectionMirror", package: "swift-reflection-mirror"),
                .product(name: "TinyFoundation", package: "AppKid"),
            ]),
        .target(
            name: "CuisineArgumentParser",
            dependencies: [
                "Cuisine",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]),
        .testTarget(
            name: "CuisineTests",
            dependencies: ["Cuisine"]),
    ]
)
