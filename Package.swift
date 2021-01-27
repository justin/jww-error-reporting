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
        .library(name: "JWWError", targets: ["JWWError"]),
        .library(name: "JWWErrorDynamic", type: .dynamic, targets: ["JWWError"])
    ],
    targets: [
        .target(name: "JWWError",
                resources: [
                    .process("Resources")
                ]
        ),
        .testTarget(name: "JWWError-Tests", dependencies: ["JWWError"]),
    ]
)
