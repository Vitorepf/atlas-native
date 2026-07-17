import Foundation

extension AtlasDayRhythm {
    public struct Windows: Sendable, Equatable {
        public let dayEnd: DateComponents?
        public let dayStart: DateComponents?
        public let sampleDays: Int

        public init(dayEnd: DateComponents?, dayStart: DateComponents?, sampleDays: Int) {
            self.dayEnd = dayEnd
            self.dayStart = dayStart
            self.sampleDays = sampleDays
        }
    }

    public struct DaySummary: Sendable, Equatable {
        public let workspaces: [String]

        public init(workspaces: [String]) {
            self.workspaces = workspaces
        }
    }
}
