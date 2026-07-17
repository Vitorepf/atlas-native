import Foundation

extension AtlasNativeSnapshot {
    public struct LiveSession: Codable, Sendable, Equatable, Identifiable {
        public enum Timing: String, Codable, Sendable, Equatable {
            case running
            case paused
            case finished
        }

        public var id: String { "\(title):\(phaseTitle):\(runningSince ?? "")" }

        public let title: String
        public let phaseTitle: String
        public let timing: Timing
        public let elapsedActiveMs: Int?
        public let runningSince: String?

        private enum CodingKeys: String, CodingKey {
            case title
            case phaseTitle = "phase_title"
            case timing
            case elapsedActiveMs = "elapsed_active_ms"
            case runningSince = "running_since"
        }

        public init(
            title: String,
            phaseTitle: String,
            timing: Timing,
            elapsedActiveMs: Int? = nil,
            runningSince: String? = nil
        ) {
            self.title = title
            self.phaseTitle = phaseTitle
            self.timing = timing
            self.elapsedActiveMs = elapsedActiveMs
            self.runningSince = runningSince
        }
    }
}
