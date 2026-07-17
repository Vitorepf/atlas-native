import WidgetKit
import SwiftUI
import AtlasCore

// Code week footer hint — peel de AtlasWidgetAccessories+CodeWeek+Body.

extension CodeWeekWidgetView {
    @ViewBuilder
    func weekLargeHint(_ week: AtlasNativeSnapshot.Week) -> some View {
        if family == .systemLarge {
            Text(CodeWeekWidgetA11y.isQuiet(week)
                 ? "abra o radar do Código para ver o grafo"
                 : "abra o radar do Código para o grafo")
                .font(.system(size: 12, design: .serif))
                .foregroundStyle(Ink.ink2)
        }
    }
}
