//
//  Package.swift
//
import PackageDescription

let package = Package(name: "SwiftTweaks",
platforms: [.macOS(.v10_12),
            .iOS(.v10),
            .tvOS(.v10),
            .watchOS(.v3)],
products: [.library(name: "SwiftTweaks",
                    targets: ["SwiftTweaks"])],
targets: [.target(name: "SwiftTweaks",
                  path: "Source"),
          .testTarget(name: "SwiftTweaksTests",
                      dependencies: ["SwiftTweaks"],
                      path: "Tests")],
swiftLanguageVersions: [.v5])
