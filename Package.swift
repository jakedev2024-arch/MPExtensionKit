// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MPExtensionKit",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "MPExtensionKit",
            targets: ["MPExtensionKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/robbiehanson/CocoaAsyncSocket.git", from: "7.6.5")
    ],
    targets: [
        .target(
            name: "MPExtensionKit",
            dependencies: [
                .product(name: "CocoaAsyncSocket", package: "CocoaAsyncSocket")
            ],
            path: "Sources",
            publicHeadersPath: "MPExtensionKit",
            cSettings: [
                .headerSearchPath("MPExtensionKit")
            ],
            linkerSettings: [
                .linkedFramework("Foundation"),
                .linkedFramework("UIKit"),
                .linkedFramework("CoreAudio"),
                .linkedFramework("VideoToolbox")
            ]
        ),
    ]
)

