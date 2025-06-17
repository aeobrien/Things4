// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MyApp", // Change to match your repo/project
    platforms: [
        .macOS(.v13), .iOS(.v16)
    ],
    products: [
        .executable(name: "MyApp", targets: ["MyApp"]),
    ],
    dependencies: [
        // Add any dependencies here if needed
    ],
    targets: [
        .executableTarget(
            name: "MyApp",
            dependencies: []
        ),
        .testTarget(
            name: "MyAppTests",
            dependencies: ["MyApp"]
        ),
    ]
)
