// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ColorPicker",
    defaultLocalization: "en",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "ColorPicker",
            targets: ["ColorPicker"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/SnapKit/SnapKit", from: "5.6.0"),
    ],
    targets: [
        .target(
            name: "ColorPicker",
            dependencies: [
                "SnapKit",
            ]
        ),
        .testTarget(
            name: "ColorPickerTests",
            dependencies: ["ColorPicker"]),
    ]
)
