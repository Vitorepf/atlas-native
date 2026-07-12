// swift-tools-version:5.9
import PackageDescription

// AtlasCore — o substrato agnóstico de plataforma do app SwiftUI puro (Fase 0).
// Foundation-only (URLSession/Codable/merge). Buildável e verificável na CLI sem
// Xcode; o app SwiftUI (com.vitor.atlas.native) linka isto depois.
//
// Verificação: `swift run AtlasCoreChecks` (Command Line Tools não trazem
// XCTest nem swift-testing, então os golden checks vivem num executável que
// sai != 0 se algo falhar — o mesmo contrato dos .test.ts do lado RN).
let package = Package(
    name: "AtlasCore",
    platforms: [.macOS(.v13), .iOS(.v17)],
    products: [
        .library(name: "AtlasCore", targets: ["AtlasCore"]),
    ],
    targets: [
        .target(name: "AtlasCore"),
        .executableTarget(name: "AtlasCoreChecks", dependencies: ["AtlasCore"]),
    ]
)
