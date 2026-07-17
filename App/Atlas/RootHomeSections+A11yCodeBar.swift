import AtlasCore
import SwiftUI

// Code top bar spoken — peel de RootHomeSections+A11y.

extension RootHomeSections {
    static func codeTopBarLabel(hub: AtlasCodeHubModel?) -> String {
        guard let hub else { return "Atlas Código" }
        if let exception = hub.exception {
            return "Atlas Código, \(exception.count) exceções em \(exception.repo)"
        }
        return "Atlas Código, código quieto"
    }
}
