// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Things4",
    platforms: [
        .macOS(.v12), .iOS(.v15)
    ],
    products: [
        .library(name: "Things4", targets: ["Things4"]),
    ],
    targets: [
        .target(
            name: "Things4",
            path: "Things4",
            exclude: [
                "Assets.xcassets",
                "Sources",
                "Things4.entitlements"
            ],
            sources: [
                "Models/Models.swift",
                "PersistenceManager.swift",
                "SyncManager.swift",
                "WorkflowEngine.swift",
                "RepeatingTaskEngine.swift",
                "DefaultList.swift",
                "URLScheme.swift",
                "SiriShortcuts.swift"
            ]
        ),
        .testTarget(
            name: "Things4Tests",
            dependencies: ["Things4"],
            path: "Things4Tests"
        ),
    ]
)
