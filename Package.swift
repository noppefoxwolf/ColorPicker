// swift-tools-version: 5.6
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
        .package(url: "https://github.com/SnapKit/SnapKit", from: "5.0.1"),
        .package(url: "https://github.com/yeahdongcn/UIColor-Hex-Swift", from: "5.1.8"),
    ],
    targets: [
        .target(
            name: "ColorPicker",
            dependencies: [
                "SnapKit",
                .product(name: "UIColorHexSwift", package: "UIColor-Hex-Swift")
            ]
        ),
        .testTarget(
            name: "ColorPickerTests",
            dependencies: ["ColorPicker"]),
    ]
)
