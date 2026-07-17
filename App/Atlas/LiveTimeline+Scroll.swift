import SwiftUI
import AtlasCore

// Scroll da timeline — peel de LiveTimeline+Surfaces.
// Rows → LiveTimeline+ScrollRows.swift
// AutoScroll → LiveTimeline+Scroll+AutoScroll.swift

extension LiveTimeline {
    var timelineScroll: some View {
        ScrollViewReader { proxy in
            ScrollView {
                timelineRows
            }
            .frame(maxHeight: min(CGFloat(rows.count) * 34 + 12, 232))
            .scrollIndicators(.hidden)
            .onChange(of: rows.count) { timelineScrollToLast(proxy) }
            .animation(reduceMotion ? nil : .easeOut(duration: 0.22), value: rows.count)
        }
    }
}
