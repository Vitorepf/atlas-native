import SwiftUI
import AtlasCore

// Banner de regressão — peel de AtlasArenaView+Failure.
// Row → AtlasArenaView+Exception+Row.swift
// Chrome → AtlasArenaView+Exception+Chrome.swift

extension AtlasArenaView {
    func exceptionBanner(_ text: String) -> some View {
        exceptionBannerChrome(exceptionBannerRow(text), text: text)
    }
}
