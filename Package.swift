// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Cuisine",
    dependencies: [
        .package(url: "https://github.com/smumriak/ShellOut.git", branch: "master"),
        .package(url: "https://github.com/apple/swift-system", from: "1.0.0"),
        .package(url: "https://github.com/philipturner/swift-reflection-mirror", branch: "main"),
        .package(url: "https://github.com/smumriak/AppKid", branch: "main"),
    ],
    targets: [
        .executableTarget(
            name: "CuisineDemo",
            dependencies: [
                "Cuisine",
            ]),
        .target(
            name: "Cuisine",
            dependencies: [
                .product(name: "ShellOut", package: "ShellOut"),
                .product(name: "SystemPackage", package: "swift-system"),
                .product(name: "ReflectionMirror", package: "swift-reflection-mirror"),
                .product(name: "TinyFoundation", package: "AppKid"),
            ]),
        .testTarget(
            name: "CuisineTests",
            dependencies: ["Cuisine"]),
    ]
)
