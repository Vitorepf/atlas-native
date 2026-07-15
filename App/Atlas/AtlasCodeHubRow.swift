import AtlasCore
import Observation
import SwiftUI

/// M1 · a linha CÓDIGO do hub. O hub **agrega**: uma linha por área, nunca uma
/// por repositório — com 3 repos ou 30 o hub tem o mesmo tamanho.
/// Estado por exceção: saudável é silêncio absoluto; só o desvio fala, e ele
/// some sozinho quando o Atlas cura.
@MainActor
@Observable
final class AtlasCodeHubModel {
    private let client: AtlasClient
    private let repos: [String]
    /// Exceção resolvida a partir de dado real. `nil` = silêncio (nunca "0".)
    private(set) var exception: Exception?

    struct Exception: Equatable {
        let repo: String
        let ruleId: String
        let count: Int
    }

    init(client: AtlasClient, repos: [String] = ["atlas-server", "atlas-native"]) {
        self.client = client
        self.repos = repos
    }

    /// Varre as áreas e mantém apenas a primeira exceção real. Falha de rede
    /// não inventa exceção nem apaga a anterior de forma silenciosa: sem
    /// resposta, a linha simplesmente não fala.
    func refresh() async {
        for repo in repos {
            guard let response = try? await client.getCodeViolations(repo: repo) else { continue }
            if let first = response.violations.first {
                exception = Exception(repo: repo, ruleId: first.ruleId, count: response.violations.count)
                return
            }
        }
        exception = nil
    }
}

struct AtlasCodeHubRow: View {
    let model: AtlasCodeHubModel
    let action: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: model.exception == nil ? "point.3.connected.trianglepath.dotted" : "exclamationmark.triangle")
                    .font(.system(size: 18))
                    .foregroundStyle(model.exception == nil ? AtlasTheme.textSecondary : AtlasCodePalette.alert)
                    .frame(width: 22)

                VStack(alignment: .leading, spacing: 3) {
                    Text("Código")
                        .font(.system(.body))
                        .foregroundStyle(AtlasTheme.textPrimary)
                    if let exception = model.exception {
                        Text("\(exception.repo) · \(exception.ruleId)")
                            .font(.system(size: 11.5))
                            .foregroundStyle(AtlasCodePalette.alert)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                }

                Spacer(minLength: 8)

                if let exception = model.exception {
                    HStack(spacing: 5) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 9, weight: .semibold))
                        Text("\(exception.count)")
                            .font(.system(size: 11, weight: .semibold))
                            .monospacedDigit()
                    }
                    .foregroundStyle(AtlasCodePalette.alert)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(AtlasCodePalette.alert.opacity(0.09)))
                    .overlay(Capsule().strokeBorder(AtlasCodePalette.alert.opacity(0.32), lineWidth: 1))
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AtlasTheme.textTertiary)
            }
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.vertical, AtlasTheme.Space.row)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.45), value: model.exception)
        .accessibilityLabel(accessibilityText)
        .accessibilityIdentifier("hub-code-row")
    }

    private var accessibilityText: String {
        guard let exception = model.exception else { return "Código, sem exceções" }
        return "Código, \(exception.count) exceção em \(exception.repo), regra \(exception.ruleId)"
    }
}
