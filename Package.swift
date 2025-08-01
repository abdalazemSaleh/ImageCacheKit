// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ImageCacheKit",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(
            name: "ImageCacheKit",
            targets: ["ImageCacheKit"]),
    ],
    targets: [
        .target(
            name: "ImageCacheKit"),
        .testTarget(
            name: "ImageCacheKitTests",
            dependencies: ["ImageCacheKit"]
        ),
    ]
)
