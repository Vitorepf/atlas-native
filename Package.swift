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
        .library(name: "AtlasImaging", targets: ["AtlasImaging"]),
    ],
    targets: [
        // StrictConcurrency cedo (5.4k linhas) — cada mês de espera encarece a
        // migração pro modo Swift 6. Warnings hoje; zerar antes do bump de tools.
        .target(name: "AtlasCore",
                swiftSettings: [.enableExperimentalFeature("StrictConcurrency")]),
        // Normalização de mídia via ImageIO/CoreGraphics — frameworks presentes
        // em iOS E macOS (zero UIKit/AppKit): UM código de HEIC→JPEG/resize
        // para as duas plataformas. Target separado para o AtlasCore continuar
        // Foundation-only.
        .target(name: "AtlasImaging", dependencies: ["AtlasCore"],
                swiftSettings: [.enableExperimentalFeature("StrictConcurrency")]),
        .executableTarget(name: "AtlasCoreChecks", dependencies: ["AtlasCore", "AtlasImaging"],
                          swiftSettings: [.enableExperimentalFeature("StrictConcurrency")]),
    ]
)
