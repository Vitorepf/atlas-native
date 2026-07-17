import SwiftUI
import AtlasCore

// Copy do empty workspace — peel de WorkspaceEditorialEmpty.
// Headline → WorkspaceEmptyStates+Editorial+Copy+Headline.swift
// Footnote → WorkspaceEmptyStates+Editorial+Copy+Footnote.swift
// Spoken → WorkspaceEmptyStates+Editorial+Spoken.swift

extension WorkspaceEditorialEmpty {
    var headline: String { editorialHeadline }
    var footnote: String { editorialFootnote }
}
