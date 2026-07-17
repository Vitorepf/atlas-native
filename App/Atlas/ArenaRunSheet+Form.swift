import SwiftUI
import AtlasCore

extension ArenaRunSheet {
    @ViewBuilder
    var formSections: some View {
        section("SUITES COM ADAPTER") {
            if installedSuites.isEmpty {
                Text("nenhuma suite com adapter instalado")
                    .font(.system(.subheadline))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityLabel("nenhuma suite com adapter instalado")
            } else {
                ForEach(installedSuites) { suite in
                    toggleRow(
                        title: suite.suite,
                        subtitle: suite.isMeasured ? "\(suite.runsTotal) rodadas" : "não medido",
                        isOn: selectedSuites.contains(suite.suite)
                    ) {
                        if selectedSuites.contains(suite.suite) { selectedSuites.remove(suite.suite) }
                        else { selectedSuites.insert(suite.suite) }
                    }
                    .accessibilityIdentifier("arena-run-suite-\(suite.suite)")
                }
            }
        }

        section("MOTOR") {
            if engines.isEmpty {
                Text("nenhum motor publicado")
                    .font(.system(.subheadline))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityLabel("nenhum motor publicado pelo servidor")
            } else {
                ForEach(engines, id: \.self) { engine in
                    toggleRow(title: engine, subtitle: nil, isOn: selectedEngine == engine) {
                        selectedEngine = engine
                    }
                    .accessibilityIdentifier("arena-run-engine-\(engine)")
                }
            }
        }

        section("BRAÇOS") {
            ForEach(AtlasArenaRunArm.allCases) { arm in
                toggleRow(title: arm.labelPT, subtitle: arm.rawValue, isOn: selectedArms.contains(arm)) {
                    if selectedArms.contains(arm), selectedArms.count > 1 { selectedArms.remove(arm) }
                    else { selectedArms.insert(arm) }
                }
                .accessibilityIdentifier("arena-run-arm-\(arm.rawValue)")
            }
        }

        section("GOVERNANÇA") {
            TextField("ator", text: $actor)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .accessibilityIdentifier(A11yID.arenaRunActor)
            TextField("motivo auditável", text: $reason, axis: .vertical)
                .lineLimit(2...4)
                .accessibilityIdentifier(A11yID.arenaRunReason)
        }
        .textFieldStyle(.roundedBorder)
    }
}
