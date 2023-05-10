// swift-tools-version:5.8

import PackageDescription

let package = Package(
    name: "slicetool",
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/nicklockwood/VectorMath.git", from: "0.4.1"),
    ],
    targets: [
        .executableTarget(
            name: "slicetool",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "VectorMath", package: "VectorMath"),
            ],
            path: "Sources"
        )
    ]
)
