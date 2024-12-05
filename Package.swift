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
    .package(url: "https://github.com/swhitty/FlyingFox.git", from: "0.20.0"),
    .package(url: "https://github.com/apple/swift-system", from: "1.4.0")
  ],
  
  targets: [
    .target(
      name: "Sweets",
      dependencies: [
        .product(name: "PostgresNIO", package: "postgres-nio"),
        .product(name: "SystemPackage", package: "swift-system"),
        .product(name: "FlyingFox", package: "FlyingFox")
      ]),
    
    .executableTarget(
      name: "Demo",
      dependencies: ["Sweets"]),

    .executableTarget(
      name: "Tests",
      dependencies: ["Sweets"]),
  ]
)
