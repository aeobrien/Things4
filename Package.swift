// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "Things4",
    platforms: [
        .macOS(.v13), .iOS(.v16)
    ],
    products: [
        .library(name: "Things4", targets: ["Things4"])
    ],
    targets: [
        .target(
            name: "Things4",
            path: "Things4",
            exclude: ["Assets.xcassets", "ContentView.swift", "Things4App.swift", "Things4.entitlements"]
        ),
        .testTarget(
            name: "Things4Tests",
            dependencies: ["Things4"],
            path: "Things4Tests"
        )
    ]
)
