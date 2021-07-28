// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "NomLibrary",
    platforms: [
            .iOS(.v13)
        ],
    products: [
        .library(
            name: "NomLibrary",
            targets: ["NomLibrary"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "NomLibrary",
            dependencies: []),
        .testTarget(
            name: "NomLibraryTests",
            dependencies: ["NomLibrary"]),
    ]
)
