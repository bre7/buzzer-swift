import PackageDescription

let beta = Version(2,0,0, prereleaseIdentifiers: ["beta"])
let package = Package(
    name: "buzzer",
    dependencies: [
		.Package(url: "https://github.com/vapor/vapor.git", majorVersion: 1, minor: 5)
    ],
    exclude: [
        "Config",
        "Database",
        "Localization",
        "Public",
        "Resources",
        "Tests",
    ]
)

