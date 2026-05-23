// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Xsnow",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "Xsnow", targets: ["Xsnow"])
    ],
    targets: [
        .executableTarget(
            name: "Xsnow"
        )
    ]
)
