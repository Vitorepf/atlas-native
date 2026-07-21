import SwiftUI
import AtlasCore

// Thread link — peel de SearchView+List.
// Spoken → SearchView+ThreadLinkSpoken.swift
// Nav → SearchView+ThreadLink+Nav.swift
// Transition → SearchView+ThreadLink+Transition.swift

struct SearchThreadLink: View {
    let thread: AtlasAiThread
    let reduceMotion: Bool
    var newBadgeSuppressed: Bool = false

    var body: some View {
        threadLinkTransition(threadNavigationLink)
    }
}
