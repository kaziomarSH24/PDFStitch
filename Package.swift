// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PDFStitch",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "PDFStitch", targets: ["PDFStitch"])
    ],
    targets: [
        .executableTarget(
            name: "PDFStitch",
            path: "Sources/PDFStitch"
        )
    ]
)
