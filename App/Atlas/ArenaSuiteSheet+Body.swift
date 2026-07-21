import SwiftUI
import AtlasCore

// Suite sheet scroll body — peel de ArenaSuiteSheet.
// Title → ArenaSuiteSheet+Body+TitleHeader.swift

extension ArenaSuiteSheet {
    var suiteScrollBody: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                suiteBodyTitle
                ForEach(suite.engines) { engine in
                    engineCard(engine)
                    ArenaPremiumHairline()
                }
                Text("Valores ausentes permanecem não medidos. Comparações só aparecem quando os dois braços foram publicados.")
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textTertiary)
            }
            .padding(AtlasTheme.Space.screen)
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: suite.engines.count)
        }
        .background(AtlasTheme.bg.ignoresSafeArea())
        .navigationTitle("Suite")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { suiteToolbar }
    }
}
