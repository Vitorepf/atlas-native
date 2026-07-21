import SwiftUI
import AtlasCore

// Provenance + heal sheets — peel de AtlasCodeView+Sheets.
// Provenance → AtlasCodeView+Sheets+ProvenanceBind.swift
// Heal → AtlasCodeView+Sheets+HealReceiptWrap.swift · Heal body → +Sheets+Heal.swift

extension AtlasCodeSheetsModifier {
  @ViewBuilder
  func provenanceAndHealSheets<Content: View>(on content: Content) -> some View {
    healReceiptWrap(on: provenanceSheetBind(on: content))
  }
}
