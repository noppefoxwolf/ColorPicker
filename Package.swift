// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ColorPicker",
    defaultLocalization: "en",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "ColorPicker",
            targets: ["ColorPicker"]
        )
    ],
    targets: [
        .target(
            name: "ColorPicker",
            dependencies: []
        ),
        .testTarget(
            name: "ColorPickerTests",
            dependencies: ["ColorPicker"]
        ),
    ]
)
