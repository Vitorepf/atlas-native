import SwiftUI
import AtlasCore

// Enum do filtro de leitura — peel de LiveTimeline+Filters.
// Apply → LiveTimeline+FilterApply.swift
// Label → LiveTimeline+FilterEnum+Label.swift

enum TimelineReadFilter: String, CaseIterable, Identifiable {
    case all
    case intent
    case tools
    case p90

    var id: String { rawValue }
}
