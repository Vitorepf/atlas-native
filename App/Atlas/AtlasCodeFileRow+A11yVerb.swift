import Foundation
import AtlasCore

/// File status verb — peel de AtlasCodeFileRow+A11y.
/// Mutate → AtlasCodeFileRow+A11yVerb+Mutate.swift
/// Transform → AtlasCodeFileRow+A11yVerb+Transform.swift

extension AtlasCodeFileRowA11y {
    static func verb(for status: AtlasCodeFileStatus) -> String {
        verbMutate(for: status) ?? verbTransform(for: status)
    }
}
