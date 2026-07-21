import SwiftUI
import AtlasCore

// Filter apply — peel de LiveTimeline+FilterEnum.
// Style → LiveTimeline+FilterApply+Style.swift
// AllP90 → LiveTimeline+FilterApply+AllP90.swift

extension TimelineReadFilter {
    func apply(to rows: [NarrativeRow]) -> [NarrativeRow] {
        if let styled = applyStyleFilter(to: rows) { return styled }
        return applyAllOrP90(to: rows)
    }
}
