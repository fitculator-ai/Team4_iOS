import ProjectDescription

let project = Project(
    name: "Fitculator",
    targets: [
        .target(
            name: "Fitculator",
            destinations: .iOS,
            product: .app,
            bundleId: "io.tuist.Fitculator",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            sources: [
                "Fitculator/Sources/App/**",
                "Fitculator/Sources/Data/**",
                "Fitculator/Sources/Domain/**",
                "Fitculator/Sources/Networking/**",
                "Fitculator/Sources/Presentation/**",
                "Fitculator/Sources/Utils/**",
            ],
            resources: ["Fitculator/Resources/**"],
            dependencies: []
        ),
        .target(
            name: "FitculatorTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "io.tuist.FitculatorTests",
            infoPlist: .default,
            sources: ["Fitculator/Tests/**"],
            resources: [],
            dependencies: [.target(name: "Fitculator")]
        ),
    ]
)
