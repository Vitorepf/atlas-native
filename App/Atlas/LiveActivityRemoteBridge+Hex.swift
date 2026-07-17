import Foundation

#if canImport(ActivityKit)
extension Data {
    var atlasHex: String {
        map { String(format: "%02x", $0) }.joined()
    }
}
#endif
