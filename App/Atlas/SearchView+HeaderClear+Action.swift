import SwiftUI
import AtlasCore

// Clear button action — peel de SearchView+HeaderClear.

extension SearchViewHeader {
    func clearSearchQuery() {
        AtlasMotion.softImpact(reduceMotion: reduceMotion)
        query = ""
    }
}
