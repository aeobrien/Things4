// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Things4",
    platforms: [
        .macOS(.v13), .iOS(.v16)
    ],
    products: [
        .executable(name: "Things4", targets: ["Things4"]),
    ],
    dependencies: [
        // Add any dependencies here if needed
    ],
    targets: [
        .executableTarget(
            name: "Things4",
            dependencies: []
        ),
        .testTarget(
            name: "Things4Tests",
            dependencies: ["Things4"]
        ),
    ]
)
