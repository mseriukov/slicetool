// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "slicetool",
    dependencies: [
        .package(url: "https://github.com/apple/swift-package-manager.git", from: "0.3.0"),
    ],
    targets: [
        .target(
            name: "slicetool",
            dependencies: ["SPMUtility"],
            path: "Sources")
    ]
)
