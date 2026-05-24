// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "MacSnow",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "MacSnow", targets: ["MacSnow"])
    ],
    targets: [
        .executableTarget(
            name: "MacSnow"
        )
    ]
)
