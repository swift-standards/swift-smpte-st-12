// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-smpte-st-12",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(name: "SMPTE ST 12", targets: ["SMPTE ST 12"])
    ],
    dependencies: [
        .package(url: "https://github.com/swift-atoms/swift-cardinal.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-rate.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "SMPTE ST 12",
            dependencies: [
                .product(name: "Cardinal", package: "swift-cardinal"),
                .product(name: "Rate", package: "swift-rate"),
            ]
        ),
        .testTarget(
            name: "SMPTE ST 12 Tests",
            dependencies: [
                .target(name: "SMPTE ST 12"),
                .product(name: "Cardinal", package: "swift-cardinal"),
                .product(name: "Rate", package: "swift-rate"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    target.swiftSettings =
        (target.swiftSettings ?? []) + [
            .strictMemorySafety(),
            .enableUpcomingFeature("ExistentialAny"),
            .enableUpcomingFeature("InternalImportsByDefault"),
            .enableUpcomingFeature("MemberImportVisibility"),
            .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
            .enableUpcomingFeature("InferIsolatedConformances"),
            .enableExperimentalFeature("Lifetimes"),
            .treatAllWarnings(as: .error),
        ]
}
