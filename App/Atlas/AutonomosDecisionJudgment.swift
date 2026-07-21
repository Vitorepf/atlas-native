import Foundation
import AtlasCore

// MARK: - Types

/// Published decision the operator can judge — projected only from backlog fields
/// that already require a decision. Never invents inbox rows.
struct AutonomosDecisionItem: Identifiable, Equatable, Hashable {
    enum Kind: Equatable, Hashable {
        case inbox
        case workOrder
    }

    let kind: Kind
    let findingHash: String
    let title: String
    let route: String
    let riskLevel: String
    let priorityScore: Int
    let decisionOptions: [String]
    let inboxItemId: String?
    let workOrderId: String?
    let createdAt: String?

    var id: String {
        switch kind {
        case .inbox: return "inbox:\(findingHash)"
        case .workOrder: return "order:\(workOrderId ?? findingHash)"
        }
    }

    var destination: AutonomosDestination {
        switch kind {
        case .inbox: return .decisionInbox(findingHash)
        case .workOrder: return .decisionOrder(workOrderId ?? findingHash)
        }
    }
}

/// Exclusive decision-surface face (WAVE-026) — one voice for list/detail chrome.
enum AutonomosDecisionFace: Equatable {
    case empty
    case loading
    case items(Int)
    case failed(String)

    var productWord: String {
        switch self {
        case .empty: return "quiet"
        case .loading: return "loading"
        case .items: return "awaiting"
        case .failed: return "failed"
        }
    }

    var spokenFace: String {
        switch self {
        case .empty: return "sem decisões publicadas"
        case .loading: return "carregando decisões"
        case .items(let n):
            return n == 1 ? "1 decisão pedida" : "\(n) decisões pedidas"
        case .failed: return "falha ao carregar decisões"
        }
    }

    var heroTitle: String {
        switch self {
        case .empty: return "Nada pede você"
        case .loading: return "Abrindo decisões…"
        case .items(let n):
            return n == 1 ? "1 decisão" : "\(n) decisões"
        case .failed: return "Decisões fora de alcance"
        }
    }

    var heroSub: String {
        switch self {
        case .empty:
            return "Sem backlog publicado que exija julgamento. Silêncio honesto."
        case .loading:
            return "Só o que o servidor já publicou."
        case .items:
            return "Só o julgamento desbloqueia."
        case .failed(let message):
            return message
        }
    }
}

// MARK: - Judgment

/// Pure decision judgment for Autônomos — rank, faces, item projection.
/// Casca only; never invents counts or rows.
enum AutonomosDecisionJudgment {

    // MARK: Projection

    /// Only rows the server marked as needing operator decision.
    static func items(from backlog: AtlasAutonomosBacklogResponse?) -> [AutonomosDecisionItem] {
        guard let backlog else { return [] }
        let inbox = backlog.inboxItems
            .filter(\.decisionRequired)
            .map { item in
                AutonomosDecisionItem(
                    kind: .inbox,
                    findingHash: item.findingHash,
                    title: item.title,
                    route: item.route,
                    riskLevel: item.riskLevel,
                    priorityScore: item.priorityScore,
                    decisionOptions: item.decisionOptions,
                    inboxItemId: item.findingHash,
                    workOrderId: nil,
                    createdAt: item.createdAt
                )
            }
        let orders = backlog.workOrders
            .filter(\.operatorDecisionRequired)
            .map { order in
                AutonomosDecisionItem(
                    kind: .workOrder,
                    findingHash: order.findingHash,
                    title: order.title,
                    route: order.route,
                    riskLevel: order.riskLevel,
                    priorityScore: order.priorityScore,
                    decisionOptions: [],
                    inboxItemId: nil,
                    workOrderId: order.workOrderId,
                    createdAt: order.createdAt
                )
            }
        return rankItems(inbox + orders)
    }

    static func decisionCount(from backlog: AtlasAutonomosBacklogResponse?) -> Int {
        items(from: backlog).count
    }

    /// Priority-first; stable title as tiebreaker.
    static func rankItems(_ items: [AutonomosDecisionItem]) -> [AutonomosDecisionItem] {
        items.sorted { lhs, rhs in
            if lhs.priorityScore != rhs.priorityScore {
                return lhs.priorityScore > rhs.priorityScore
            }
            return lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
        }
    }

    // MARK: Faces

    /// Exclusive face for the decisions surface.
    /// - loading: area selected, no backlog yet, no error
    /// - failed: control/public error while decisions are the focus
    /// - items: published count > 0
    /// - empty: silence (nil backlog without load, or zero decision rows)
    static func face(
        backlog: AtlasAutonomosBacklogResponse?,
        areaSelected: Bool,
        error: String?
    ) -> AutonomosDecisionFace {
        if let error, !error.isEmpty, backlog == nil {
            return .failed(error)
        }
        if areaSelected, backlog == nil, error == nil || error?.isEmpty == true {
            return .loading
        }
        let count = decisionCount(from: backlog)
        if count > 0 { return .items(count) }
        if let error, !error.isEmpty {
            return .failed(error)
        }
        return .empty
    }

    static func item(
        matching destination: AutonomosDestination,
        in backlog: AtlasAutonomosBacklogResponse?
    ) -> AutonomosDecisionItem? {
        let all = items(from: backlog)
        switch destination {
        case .decisionInbox(let hash):
            return all.first { $0.kind == .inbox && $0.findingHash == hash }
        case .decisionOrder(let id):
            return all.first {
                $0.kind == .workOrder && ($0.workOrderId == id || $0.findingHash == id)
            }
        default:
            return nil
        }
    }

    // MARK: List order (catalog)

    /// Judgment order for the operator catalog.
    /// When `awaitingUnitIDs` is non-empty (hydrated signal bound to units),
    /// those rise first; quiet/paused last. Empty set → WAVE-025 live-before-quiet.
    static func rankUnits(
        _ units: [AutonomosUnit],
        awaitingUnitIDs: Set<String> = []
    ) -> [AutonomosUnit] {
        units.enumerated().sorted { lhs, rhs in
            let lAwait = awaitingUnitIDs.contains(lhs.element.id)
            let rAwait = awaitingUnitIDs.contains(rhs.element.id)
            if lAwait != rAwait { return lAwait && !rAwait }
            let lQuiet = lhs.element.paused
            let rQuiet = rhs.element.paused
            if lQuiet != rQuiet { return !lQuiet && rQuiet }
            return lhs.offset < rhs.offset
        }.map(\.element)
    }

    /// When area backlog is hydrated with decisions but units are local-only
    /// (no wire unit↔area), return empty — never pin “awaiting” on a random unit.
    static func awaitingUnitIDs(
        units: [AutonomosUnit],
        backlog: AtlasAutonomosBacklogResponse?,
        boundUnitID: String?
    ) -> Set<String> {
        guard decisionCount(from: backlog) > 0 else { return [] }
        guard let boundUnitID,
              units.contains(where: { $0.id == boundUnitID }) else {
            return []
        }
        return [boundUnitID]
    }

}
