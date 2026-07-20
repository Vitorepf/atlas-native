import Foundation

extension AutonomosModel {
    func operatorUnit(id: String) -> AutonomosUnit? {
        operatorUnits.first { $0.id == id }
    }

    @discardableResult
    func createOperatorUnit(name: String, charter: String) -> AutonomosUnit {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedCharter = charter.trimmingCharacters(in: .whitespacesAndNewlines)
        let unit = AutonomosUnit(
            id: UUID().uuidString,
            name: trimmedName.isEmpty ? "Sem nome" : trimmedName,
            charter: trimmedCharter.isEmpty ? "Escopo ainda sem carta." : trimmedCharter,
            createdAt: Date(),
            paused: true
        )
        operatorUnits.insert(unit, at: 0)
        return unit
    }

    func setOperatorUnitPaused(id: String, paused: Bool) {
        guard let index = operatorUnits.firstIndex(where: { $0.id == id }) else { return }
        operatorUnits[index].paused = paused
    }

    func removeOperatorUnit(id: String) {
        operatorUnits.removeAll { $0.id == id }
    }
}
