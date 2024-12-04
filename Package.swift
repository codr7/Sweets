// swift-tools-version:6.0.2

import PackageDescription

let package = Package(
  name: "Sweets",

  products: [
    .library(
      name: "SweetsStatic",
      type: .static,
      targets: ["Sweets"]),

    .library(
      name: "SweetsDynamic",
      type: .dynamic,
      targets: ["Sweets"]),

    .executable(
      name: "Demo",
      targets: ["Demo"]),

    .executable(
      name: "Tests",
      targets: ["Tests"])
  ],

  dependencies: [
    .package(url: "https://github.com/vapor/postgres-nio.git", from: "1.14.0"),
    .package(url: "https://github.com/apple/swift-nio.git", from: "2.0.0"),
    .package(url: "https://github.com/apple/swift-nio-http2.git", from: "1.31.0"),
    .package(url: "https://github.com/apple/swift-nio-ssl.git", from: "2.27.0"),
    .package(url: "https://github.com/apple/swift-system", from: "1.4.0"),
  ],
  
  targets: [
    .target(
      name: "Sweets",
      dependencies: [
        .product(name: "PostgresNIO", package: "postgres-nio"),
        .product(name: "NIOCore", package: "swift-nio"),
        .product(name: "NIOHTTP2", package: "swift-nio-http2"),
        .product(name: "NIOSSL", package: "swift-nio-ssl"),
        .product(name: "SystemPackage", package: "swift-system"),
      ]),
    
    .executableTarget(
      name: "Demo",
      dependencies: ["Sweets"]),

    .executableTarget(
      name: "Tests",
      dependencies: ["Sweets"]),
  ]
)
