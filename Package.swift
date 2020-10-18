// swift-tools-version:5.3
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
        .package(name: "JWWCore", url: "git@github.com:justin/jww-standard-lib.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "JWWError",
            dependencies: ["JWWCore"]),
        .testTarget(name: "JWWError-Tests", dependencies: ["JWWError"]),
    ]
)
