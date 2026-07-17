import SwiftUI

// Queue row text — peel de QueuedFollowUpRow.
// Position → QueuedFollowUpRow+Text+Position.swift
// Message → QueuedFollowUpRow+Text+Message.swift

extension QueuedFollowUpRow {
    var rowText: some View {
        VStack(alignment: .leading, spacing: 4) {
            rowPositionCaption
            rowMessagePreview
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(rowSpokenLabel)
    }
}
