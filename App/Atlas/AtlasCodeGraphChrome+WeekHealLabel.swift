import SwiftUI
import AtlasCore

// Week heal button label — peel de AtlasCodeGraphChrome+WeekHeal.
// Lead → AtlasCodeGraphChrome+WeekHealLabel+Lead.swift
// Chevron → AtlasCodeGraphChrome+WeekHealLabel+Chevron.swift

extension AtlasCodeView {
    var weekHealReceiptLabel: some View {
        weekHealChrome(
            HStack(spacing: 8) {
                weekHealReceiptLabelLead
                weekHealReceiptLabelChevron
            }
        )
    }
}
