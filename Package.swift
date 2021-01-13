// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "SwiftTweaks",
    platforms: [.iOS(.v10)],
    products: [.library(name: "SwiftTweaks", targets: ["SwiftTweaks"])],
    targets: [
        .target(
            name: "SwiftTweaks",
            path: "SwiftTweaks",
            exclude: ["Info.plist", "SwiftTweaks.h"]
        ),
        .testTarget(
            name: "SwiftTweaksTests",
            dependencies: ["SwiftTweaks"],
            path: "SwiftTweaksTests",
            exclude: ["Info.plist"]
        )
    ]
)
