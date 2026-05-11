// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "mvBingo",
    platforms: [
        .iOS(.v26),
        .macOS(.v26),
    ],
    products: [
        .library(name: "mvBingoKit", targets: ["mvBingoKit"]),
        .library(name: "mvBingoUI", targets: ["mvBingoUI"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/scalecode-solutions/scalecode-metal-plugin.git",
            from: "1.0.1"
        ),
    ],
    targets: [
        .target(
            name: "mvBingoKit",
            path: "Sources/mvBingoKit"
        ),
        .target(
            name: "mvBingoUI",
            dependencies: ["mvBingoKit"],
            path: "Sources/mvBingoUI",
            exclude: ["Shaders"],
            plugins: [
                .plugin(name: "MetalShadersPlugin", package: "scalecode-metal-plugin"),
            ]
        ),
        .testTarget(
            name: "mvBingoKitTests",
            dependencies: ["mvBingoKit"],
            path: "Tests/mvBingoKitTests"
        ),
    ]
)
