// swift-tools-version:4.2

import PackageDescription

let package = Package(
	name: "ModelAssistant",
	products: [
		// Products define the executables and libraries produced by a package, and make them visible to other packages.
		.library(
			name: "ModelAssistant",
			targets: ["ModelAssistant"]
		)
	],
	dependencies: [],
	targets: [
		.target(name: "ModelAssistant",
				dependencies: [],
				path: "Source"
		),
		.testTarget(name: "ModelAssistant iOS Tests",
					dependencies: ["ModelAssistant"],
					path: "Tests"
		),
		]
)
