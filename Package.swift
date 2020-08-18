// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "JWW Error Reporting",
    platforms: [
        .iOS(.v12),
        .macOS(.v10_14),
        .watchOS(.v5),
        .tvOS(.v12)
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
