import Foundation
import AtlasCore

public func runAtlasIDChecks(_ check: (String, Bool) -> Void) {
    print("\nAtlasIDs (single-value Codable):")

    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    do {
        let trace = TraceID("trace-typed-1")
        let data = try encoder.encode(trace)
        let encoded = String(data: data, encoding: .utf8)
        let decoded = try decoder.decode(TraceID.self, from: data)
        check("TraceID codifica como string única", encoded == "\"trace-typed-1\"")
        check("TraceID roundtrip preserva rawValue", decoded == trace)
    } catch {
        check("TraceID Codable roundtrip", false)
    }

    do {
        let patch = PatchID("patch-typed-1")
        let data = try encoder.encode(patch)
        let encoded = String(data: data, encoding: .utf8)
        let decoded = try decoder.decode(PatchID.self, from: data)
        check("PatchID codifica como string única", encoded == "\"patch-typed-1\"")
        check("PatchID roundtrip preserva rawValue", decoded == patch)
    } catch {
        check("PatchID Codable roundtrip", false)
    }
}
