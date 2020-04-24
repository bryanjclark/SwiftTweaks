// swift-tools-version:5.1
//
//  Package.swift
//
//
//
import PackageDescription

let package = Package(name: "SwiftTweaks",
platforms: [.iOS(.v10)],
products: [.library(name: "SwiftTweaks",
                    targets: ["SwiftTweaks"])],
targets: [.target(name: "SwiftTweaks",
                  path: "Source"),
          .testTarget(name: "SwiftTweaksTests",
                      dependencies: ["SwiftTweaks"],
                      path: "Tests")],
swiftLanguageVersions: [.v5])
