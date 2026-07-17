import Foundation

extension AtlasRoute {
    public static func autonomosLive(area: String) -> String {
        "\(autonomosLoop(area: area))/live"
    }

    public static func autonomosCycles(area: String) -> String {
        "\(autonomosLoop(area: area))/cycles"
    }

    public static func autonomosCycleRevert(area: String, cycle: String) -> String {
        "/ai/software-company-stewardship/autonomos/\(component(area))/cycles/\(component(cycle))/revert"
    }

    public static func autonomosDone(area: String) -> String {
        "\(autonomosLoop(area: area))/done"
    }

    public static func autonomosBacklog(area: String) -> String {
        "\(autonomosLoop(area: area))/backlog"
    }

    public static func autonomosRunControl(area: String) -> String {
        "\(autonomosLoop(area: area))/run-control"
    }

    public static func autonomosStartRun(area: String) -> String {
        "\(autonomosLoop(area: area))/start-run"
    }

    public static func autonomosTransfer(area: String) -> String {
        "\(autonomosLoop(area: area))/transfer"
    }

    public static func autonomosTransferStatus(area: String, handoffId: String) -> String {
        "\(autonomosTransfer(area: area))/\(component(handoffId))"
    }

    public static func autonomosOperatorDecision(area: String) -> String {
        "\(autonomosLoop(area: area))/operator-decision"
    }

    static func autonomosLoop(area: String) -> String {
        "/ai/software-company-stewardship/loop/\(component(area))"
    }
}
