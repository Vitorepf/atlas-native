import Foundation

// MARK: - Types

/// WAVE-158: one can_do law for partida doors (Home · Workspace · Radar).
/// Never invents stop/steer/write — those live on conversation / Autônomos faces.
enum PartidaCanDoJudgment {

    struct Result: Equatable {
        let canDo: AgenticOccasionPack.CanDo
        let absences: [String]
    }

    // MARK: Home

    /// Home doors are navigation only. Live/stop/escolher only on open thread.
    static func home(
        autonomosFace: HomeOpsAutonomosFace,
        liveCount: Int
    ) -> Result {
        var absences: [String] = []

        switch autonomosFace {
        case .awaiting:
            absences.append(
                "abrir Autônomos para assinar decisões — NL da Home não decide"
            )
        case .incident:
            absences.append(
                "incidente na frota Autônomos — abrir Autônomos; NL Home não controla loop"
            )
        case .liveLoop:
            absences.append(
                "loop Autônomos ao vivo — controle (pause/kill) só no Hub Autônomos"
            )
        case .fleetPressure:
            absences.append(
                "frota pede atenção — abrir Autônomos; Home só navega"
            )
        case .unbound:
            absences.append("Autônomos ainda unbound — catálogo sem área hidratada")
        case .quiet:
            break
        }

        if liveCount > 0 {
            absences.append(
                "sessoes vivas na Home — stop/escolher/steer só na conversa aberta (não invente cta_only_run_stop aqui)"
            )
        }

        // Nav doors (Autônomos/Arena/Código) are face navigation, not run control.
        // Read chat is the honest pack can_do for partida.
        return Result(canDo: .readChat, absences: absences)
    }

    // MARK: Workspace

    static func workspace(scopedLiveCount: Int) -> Result {
        var absences: [String] = []
        if scopedLiveCount > 0 {
            absences.append(
                "live neste workspace — controle do run só na thread aberta"
            )
        }
        absences.append("workspace pack é leitura/navegação — sem stop/steer inventados")
        return Result(canDo: .readChat, absences: absences)
    }

    // MARK: Radar

    /// Heal CTA is on single-repo Code surface, not multi-repo Radar list.
    /// `hasHealFaceCTA` reserved if a local radar heal button is ever published.
    static func radar(
        hasHealFaceCTA: Bool,
        attentionCount: Int
    ) -> Result {
        var absences: [String] = []
        if attentionCount > 0 {
            absences.append(
                "radar com sem-retorno — curar/heal na superfície do repo, não no pack NL do radar"
            )
        }
        if hasHealFaceCTA {
            // Face CTA local published on this radar chrome.
            return Result(canDo: .faceCTALocal, absences: absences)
        }
        absences.append(
            "radar partida = leitura/julgamento; CTAs de cura só com face publicada no repo"
        )
        return Result(canDo: .readChat, absences: absences)
    }
}
