import SwiftUI
import AtlasCore

// WAVE-156 density peel — MapShell bind + run control actions

extension AutonomosMapShell {
    var areaBindFace: AutonomosAreaBindFace {
        AutonomosAreaBindJudgment.face(
            areas: model.areas,
            selectedAreaID: model.selectedAreaID
        )
    }

    var controlFace: AutonomosRunControlFace {
        AutonomosRunControlJudgment.face(
            areaSelected: model.selectedArea != nil,
            canControl: model.canControlSelectedArea,
            live: model.live
        )
    }

    var controlReceiptLine: String? {
        AutonomosRunControlJudgment.receiptLine(
            receipt: model.lastControlReceipt,
            startReceipt: model.lastStartRunReceipt,
            error: model.controlError
        )
    }

    func bindAreaIfNeeded() async {
        if model.areas.isEmpty {
            await model.load()
        }
        guard model.selectedAreaID == nil else {
            await model.refreshSelected()
            return
        }
        // WAVE-065: 0 → silence · 1 → auto · N → chooser (not unbound forever).
        if let id = AutonomosAreaBindJudgment.autoBindID(areas: model.areas) {
            await model.selectArea(id)
        } else if AutonomosAreaBindJudgment.face(
            areas: model.areas,
            selectedAreaID: model.selectedAreaID
        ).needsChooser {
            showAreaBindChooser = true
        }
    }

    func applyRunControl(
        _ action: AutonomosRunControlAction,
        actor: String,
        reason: String
    ) async {
        switch action {
        case .pause:
            await model.control(.pause, operatorActor: actor, reason: reason)
        case .resume:
            await model.control(.resume, operatorActor: actor, reason: reason)
        case .kill:
            await model.control(.kill, operatorActor: actor, reason: reason)
        case .startExecute:
            await model.startRun(mode: .execute, operatorActor: actor, operatorReason: reason)
        case .startDryRun:
            await model.startRun(mode: .dryRun, operatorActor: actor, operatorReason: reason)
        }
    }
}
