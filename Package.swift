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
      name: "Tests",
      targets: ["Tests"])
  ],

  dependencies: [
    .package(url: "https://github.com/vapor/postgres-nio.git", from: "1.14.0"),
    .package(url: "https://github.com/apple/swift-nio.git", from: "2.0.0"),
    .package(url: "https://github.com/apple/swift-system", from: "1.4.0"),
  ],
  
  targets: [
    .target(
      name: "Sweets",
      dependencies: [
        .product(name: "PostgresNIO", package: "postgres-nio"),
        .product(name: "NIOCore", package: "swift-nio"),
        .product(name: "SystemPackage", package: "swift-system"),
      ]),
    
    .executableTarget(
      name: "Tests",
      dependencies: ["Sweets"]),
  ]
)
