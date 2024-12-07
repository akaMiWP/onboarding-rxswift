// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Operators",
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "5.1.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "Operators",
            dependencies: [
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "RxRelay", package: "RxSwift") // Explicitly add RxRelay
            ]
        ),
    ]
)
