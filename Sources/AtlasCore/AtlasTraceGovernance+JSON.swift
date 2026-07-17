import Foundation

/// Leitura tolerante do JSON de governança — peel de AtlasTraceGovernance.
extension AtlasTraceGovernance {
    static func object(_ value: JSONValue?) -> [String: JSONValue]? {
        if case .object(let dict) = value { return dict }
        return nil
    }

    static func array(_ value: JSONValue?) -> [JSONValue]? {
        if case .array(let items) = value { return items }
        return nil
    }

    static func planStepTitles(from item: [String: JSONValue]) -> [String] {
        let plan = object(item["plan"])
            ?? object(item["execution_plan"])
            ?? object(item["archived_plan"])
        guard let steps = array(plan?["steps"]) else { return [] }
        return steps.compactMap { raw in
            if let title = string(raw) { return title }
            guard let step = object(raw) else { return nil }
            return string(step["title"]) ?? string(step["label"]) ?? string(step["id"])
        }
    }

    static func string(_ value: JSONValue?) -> String? {
        if case .string(let text) = value, !text.isEmpty { return text }
        return nil
    }

    static func int(_ value: JSONValue?) -> Int? {
        switch value {
        case .number(let number): return Int(number)
        case .string(let text): return Int(text)
        default: return nil
        }
    }
}
