// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PureKFD",
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.10.0")),
        .package(url: "https://github.com/Lrdsnow/JASON.git", .revisionItem("72ec8fcdb3df09057d22e71680bca8a643967d47")),
        .package(url: "https://github.com/OpenCombine/OpenCombine.git", from: "0.14.0"),
        .package(url: "https://github.com/Lrdsnow/Zip.git", .revisionItem("48ff25a76bf37a2922e41e129f56404d9b4eee87"))
    ],
    targets: [
        .executableTarget(
            name: "PureKFD",
            dependencies: [
                .product(name: "Alamofire", package: "Alamofire"),
                .product(name: "JASON", package: "JASON"),
                .product(name: "Zip", package: "Zip"),
                .product(name: "OpenCombine", package: "OpenCombine"),
                .product(name: "OpenCombineFoundation", package: "OpenCombine"),
                .product(name: "OpenCombineDispatch", package: "OpenCombine")
            ]
        ),
    ]
)
