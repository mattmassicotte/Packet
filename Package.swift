// swift-tools-version: 5.10

import PackageDescription

let package = Package(
	name: "Packet",
	platforms: [
		.macOS(.v10_15),
		.iOS(.v12),
		.tvOS(.v12),
		.watchOS(.v5),
		.macCatalyst(.v13),
		.visionOS(.v1),
	],
	products: [
		.library(name: "Packet", targets: ["Packet"]),
	],
	targets: [
		.target(name: "Packet"),
		.testTarget(name: "PacketTests", dependencies: ["Packet"]),
	]
)

let swiftSettings: [SwiftSetting] = [
	.enableExperimentalFeature("StrictConcurrency"),
	.enableUpcomingFeature("DisableOutwardActorInference"),
]

for target in package.targets {
	var settings = target.swiftSettings ?? []
	settings.append(contentsOf: swiftSettings)
	target.swiftSettings = settings
}
