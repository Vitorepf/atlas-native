import SwiftUI
import AtlasCore

// App scene lifecycle — peel de AtlasApp.
// Bootstrap → AtlasApp+Lifecycle+Bootstrap.swift
// ScenePhase → AtlasApp+Lifecycle+ScenePhase.swift

extension AtlasApp {
    func atlasSceneLifecycle<Content: View>(_ content: Content) -> some View {
        atlasScenePhaseLifecycle(atlasSceneBootstrap(content))
    }
}
