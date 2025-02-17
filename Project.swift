import ProjectDescription

let project = Project(
    name: "Fitculator",
    options: .options(
      automaticSchemesOptions: .disabled,
      defaultKnownRegions: ["en", "ko"],
      developmentRegion: "ko",
      textSettings: .textSettings(usesTabs: false, indentWidth: 4, tabWidth: 4)
    ),
    targets: [
        .target(
            name: "Fitculator",
            destinations: .iOS,
            product: .app,
            bundleId: "io.tuist.Fitculator",
            deploymentTargets: .iOS("17.0"),
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
            dependencies: [
                .external(name: "Alamofire"),
                .external(name: "Kingfisher")
            ]
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
