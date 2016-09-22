import PackageDescription

let package = Package(
    name: "Globus",
    dependencies: [
        .Package(url: "https://oprandi@bitbucket.org/appculture/uiimagecolors-ios.git", majorVersion: 0, minor: 2)
    ]
)

