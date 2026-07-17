import Foundation

// Envelope JSON v1 + registro diário — peel de AtlasDayRhythm (régua ~120).

struct AtlasDayRhythmEnvelope: Codable {
    var v: Int
    var days: [AtlasDayRhythmDayRecord]
}

struct AtlasDayRhythmDayRecord: Codable {
    var date: String
    var first: String?
    var last: String?
    var workspaces: [String]

    init(date: String, first: String? = nil, last: String? = nil, workspaces: [String] = []) {
        self.date = date
        self.first = first
        self.last = last
        self.workspaces = workspaces
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        date = try container.decode(String.self, forKey: .date)
        first = try container.decodeIfPresent(String.self, forKey: .first)
        last = try container.decodeIfPresent(String.self, forKey: .last)
        workspaces = try container.decodeIfPresent([String].self, forKey: .workspaces) ?? []
    }
}
