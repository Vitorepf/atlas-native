import AtlasCore
import Observation
import SwiftUI

/// M5 · Espelho — o que sairia do Mac, e o que a varredura encontrou.
///
/// Contrato visual: `docs/proposals/atlas-code-mobile.html` (tela M5).
/// Espelhar é OPERAÇÃO: o Atlas faz sozinho; esta superfície informa e nunca
/// pede aprovação. O host é adaptador — aparece como detalhe, jamais como
/// substantivo primário. Segredo encontrado = nada sai, e a regra é dita
/// pelo nome (nunca o segredo).
@MainActor
@Observable
final class AtlasCodeMirrorModel {
    private let client: AtlasClient
    private let repo: String
    private(set) var response: AtlasCodeMirrorResponse?

    init(client: AtlasClient, repo: String) {
        self.client = client
        self.repo = repo
    }

    func refresh() async {
        // Sem resposta, a seção não fala — ausência nunca vira "0 a espelhar".
        //
        // E falha NÃO APAGA a leitura anterior: `response = try?` zerava o
        // card no primeiro fetch que caísse, e o estado que mais precisa de
        // olho — espelho BLOQUEADO POR SEGREDO — sumia da tela por causa de
        // uma queda de rede. O alarme aceso fica aceso até uma leitura REAL
        // dizer o contrário; só resposta nova escreve o estado.
        if let fresh = try? await client.getCodeMirror(repo: repo) {
            response = fresh
        }
    }
}

struct AtlasCodeMirrorCard: View {
    let response: AtlasCodeMirrorResponse

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("Espelho")
                    .font(AtlasFont.serif(18, .semibold))
                    .foregroundStyle(AtlasTheme.textPrimary)
                Spacer()
                if let host = response.mirror?.host {
                    // Adaptador, não fundação: o host é uma nota de rodapé.
                    Text(host)
                        .font(AtlasFont.mono(9))
                        .foregroundStyle(AtlasTheme.textTertiary)
                }
            }
            headline
            if case .blocked(let rules) = response.state {
                HStack(spacing: 5) {
                    ForEach(rules, id: \.self) { rule in
                        Text(rule)
                            .font(AtlasFont.mono(9))
                            .foregroundStyle(AtlasCodePalette.alert)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .overlay(Capsule().strokeBorder(AtlasCodePalette.alert.opacity(0.3), lineWidth: 1))
                    }
                }
            }
        }
        .padding(13)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(background, in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(borderColor, lineWidth: 1))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityText)
        .accessibilityIdentifier("code-mirror")
    }

    @ViewBuilder
    private var headline: some View {
        switch response.state {
        case .mirrored:
            label("tudo espelhado · a verdade fica no Mac", color: AtlasTheme.textSecondary, icon: "checkmark")
        case .pending(let commits):
            label(
                commits == 1 ? "1 commit a espelhar · o Atlas envia sozinho" : "\(commits) commits a espelhar · o Atlas envia sozinho",
                color: AtlasTheme.textSecondary,
                icon: "arrow.up"
            )
        case .blocked:
            label("segredo detectado · nada sai da máquina", color: AtlasCodePalette.alert, icon: "exclamationmark.triangle")
        case .noMirror:
            label("sem espelho configurado", color: AtlasTheme.textTertiary, icon: "circle.dashed")
        case .unknown:
            label("espelho ainda não conhecido", color: AtlasTheme.textTertiary, icon: "questionmark.circle")
        }
    }

    private func label(_ text: String, color: Color, icon: String) -> some View {
        HStack(spacing: 7) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .semibold))
            Text(text)
                .font(.system(size: 12.5))
        }
        .foregroundStyle(color)
    }

    private var background: Color {
        if case .blocked = response.state { return AtlasCodePalette.alert.opacity(0.05) }
        return AtlasTheme.surface.opacity(0.4)
    }

    private var borderColor: Color {
        if case .blocked = response.state { return AtlasCodePalette.alert.opacity(0.35) }
        return AtlasTheme.separator
    }

    private var accessibilityText: String {
        switch response.state {
        case .mirrored: return "Espelho: tudo espelhado"
        case .pending(let commits): return "Espelho: \(commits) commits a espelhar, o Atlas envia sozinho"
        case .blocked(let rules): return "Espelho bloqueado: segredo detectado, regras \(rules.joined(separator: ", "))"
        case .noMirror: return "Espelho: nenhum configurado"
        case .unknown: return "Espelho: estado ainda desconhecido"
        }
    }
}
