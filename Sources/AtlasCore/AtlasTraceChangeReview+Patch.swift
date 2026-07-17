import Foundation

extension AtlasTraceChangeReview {
    public struct Patch: Decodable, Sendable, Identifiable {
        public let id: String
        public let baseRef: String?
        public let headRef: String?
        public let diffHash: String?
        public let changedFiles: [String]
        public let createdFiles: [String]
        public let deletedFiles: [String]
        public let riskFlags: [String]
        /// Estado canônico atual por arquivo para este artefato imutável. A
        /// ausência preserva compatibilidade com uma API ainda sem C16.
        public let fileReviews: [FileReview]
        public let createdAt: String?
        public let diffURL: String
        public var patchID: PatchID { PatchID(id) }

        private enum CodingKeys: String, CodingKey {
            case id, baseRef, headRef, diffHash, changedFiles, createdFiles, deletedFiles, riskFlags, fileReviews, createdAt
            case diffURL = "diffUrl"
        }

        public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            id = try values.decode(String.self, forKey: .id)
            baseRef = try values.decodeIfPresent(String.self, forKey: .baseRef)
            headRef = try values.decodeIfPresent(String.self, forKey: .headRef)
            diffHash = try values.decodeIfPresent(String.self, forKey: .diffHash)
            changedFiles = try values.decode([String].self, forKey: .changedFiles)
            createdFiles = try values.decode([String].self, forKey: .createdFiles)
            deletedFiles = try values.decode([String].self, forKey: .deletedFiles)
            riskFlags = try values.decode([String].self, forKey: .riskFlags)
            fileReviews = try values.decodeIfPresent([FileReview].self, forKey: .fileReviews) ?? []
            createdAt = try values.decodeIfPresent(String.self, forKey: .createdAt)
            diffURL = try values.decode(String.self, forKey: .diffURL)
        }

        public func contains(_ filePath: String) -> Bool {
            changedFiles.contains(filePath) || createdFiles.contains(filePath) || deletedFiles.contains(filePath)
        }
    }

    public struct FileReview: Decodable, Sendable, Identifiable {
        public let filePath: String
        public let action: Action
        public let actor: String?
        public let note: String?
        public let decidedAt: String?

        public var id: String { filePath }
    }
}
