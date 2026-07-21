import SwiftUI
import AtlasCore

// IDLE-COMPRESS Arena peels

struct ArenaPremiumEngineTitle: View {
    let engineID: String
    let options: [String]
    let onSelect: (String) -> Void

    var body: some View {
        if options.count > 1 {
            Menu {
                ForEach(options, id: \.self) { engine in
                    Button {
                        onSelect(engine)
                    } label: {
                        if engine == engineID {
                            Label(ArenaDisplay.engine(engine), systemImage: "checkmark")
                        } else {
                            Text(ArenaDisplay.engine(engine))
                        }
                    }
                }
            } label: {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(ArenaDisplay.engine(engineID))
                        .font(AtlasFont.serif(33))
                        .foregroundStyle(AtlasTheme.textPrimary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .accessibilityHidden(true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .accessibilityLabel(ArenaScoreJudgment.spokenMeasuredEngine(engineID))
            .accessibilityHint(ArenaScoreJudgment.measuredEngineHint)
            .accessibilityIdentifier(A11yID.arenaPremiumEnginePicker)
        } else {
            Text(ArenaDisplay.engine(engineID))
                .font(AtlasFont.serif(33))
                .foregroundStyle(AtlasTheme.textPrimary)
        }
    }
}

