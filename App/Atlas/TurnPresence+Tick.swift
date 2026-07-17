import Foundation
import UIKit
import AtlasCore

// tick/lastPresence — peel de TurnPresence (régua anti-inchaço).

@MainActor
extension TurnPresence {
    func tick(_ id: ObjectIdentifier) {
        guard let entry = entries[id] else { return }
        guard let model = entry.model else { cleanup(id); return }
        let presence = model.currentExecutionPresence
        let trace = model.currentExecutionPresenceTraceId

        if let p = presence, let trace {
            // C10: rodando com checkpoint REAL do plano, a fase da Lock
            // Screen é "N/M · etapa"; sem plano, a fase pública da presença.
            var phase: String? = nil
            if p.timing == .running,
               let prog = model.bubbles.last(where: { $0.traceId == trace })?.executionProgress {
                phase = "\(prog.current)/\(prog.total) · \(prog.title)"
            }
            // Sessão viva (running OU paused): a MESMA Activity atravessa
            // stream fechado, pausa aguardando decisão e reconexão.
            if entry.activityKey != nil && entry.activityKey != trace {
                finishActivity(entry, presence: lastPresence(model, key: entry.activityKey))
            }
            if !entry.ongoing || !entry.activityStarted {
                if !entry.ongoing { entry.startedAt = Date() }   // base legada
                entry.ongoing = true
                startActivity(entry, traceId: trace, presence: p, phaseOverride: phase)
                broadcastCount()
                syncRunning()
            } else {
                updateActivity(entry, presence: p, phaseOverride: phase)
            }
        } else if entry.ongoing {
            // Fase pública terminal (Concluído/Falhou) ou fim legado — nunca
            // "porque isSending virou falso": a presença é quem decide.
            entry.ongoing = false
            let final = lastPresence(model, key: entry.activityKey)
            finishActivity(entry, presence: final)
            broadcastCount()
            if UIApplication.shared.applicationState == .active, !entry.visible {
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            }
            // A permissão PRIMEIRO, e esperando o veredito: pedir depois de
            // notificar fazia a primeira notificação da vida do app ser sempre
            // descartada em silêncio — justamente a que prova ao operador que a
            // presença funciona. Continua sendo no primeiro turno concluído (o
            // momento de valor real), nunca no launch.
            Task { @MainActor in
                await requestPermissionOnce()
                notifyIfAway(entry, model: model, finalPresence: final)
            }
            syncRunning()
        }
    }

    /// A presença final da bolha dona da Activity (fase "Concluído"/"Falhou").
    func lastPresence(_ model: ConversationModel, key: TraceID?) -> AtlasExecutionPresence? {
        guard let key else { return nil }
        return model.bubbles.last(where: { $0.traceId == key })?.executionPresence
    }
}
