// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "JWW Error Reporting",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(name: "JWWError", targets: ["JWWError"]),
    ],
    targets: [
        .target(name: "JWWError"),
        .testTarget(name: "JWWError-Tests", dependencies: ["JWWError"]),
    ]
)
