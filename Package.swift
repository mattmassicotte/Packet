// swift-tools-version: 5.10

import PackageDescription

let package = Package(
	name: "Packet",
	platforms: [
		.macOS(.v12),
		.iOS(.v13),
		.tvOS(.v15),
		.watchOS(.v6),
		.macCatalyst(.v15),
		.visionOS(.v1),
	],
	products: [
		.library(name: "Packet", targets: ["Packet"]),
	],
	targets: [
		.target(name: "Packet"),
        .testTarget(name: "PacketTests", dependencies: ["Packet"], resources: [.copy("Resources/ipsum100k.txt")]),
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
