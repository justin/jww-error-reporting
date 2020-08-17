// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "JWW Error Reporting",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .watchOS(.v6),
        .tvOS(.v13)
    ],
    products: [
        .library(
            name: "JWWError",
            targets: ["JWWError"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "JWWError",
            dependencies: []),
        .testTarget(name: "JWWError-Tests", dependencies: ["JWWError"]),
    ]
)
