import Foundation
import AtlasCore

public func runAtlasAiStreamFrameChecks(_ check: (String, Bool) -> Void) {
    print("\nAtlas AI · SSE frame bytes equivalem ao caminho String:")

    let corpus = [
        "event: message\ndata: {\"trace_id\":\"t1\",\"sequence\":3,\"type\":\"delta\",\"content\":\"olá\"}",
        "event: token\ndata: {\"trace_id\":\"t\",\"sequence\":1}",
        "event: done\ndata: {\"trace_id\":\"t\",\"status\":\"succeeded\",\"last_sequence\":9}",
        "event: done\ndata: {\"trace_id\":\"t\"}",
        "event: error\ndata: {\"code\":\"boom\"}",
        "event: heartbeat\ndata: {}",
        "event: message\n: comentário",
        "data: {não é json}",
        "data: {\"sequence\":1}",
        "data: {\"trace_id\":\"t\"}",
        "data: {\"trace_id\":\"t\",\"sequence\":1,\ndata: \"content\":\"x\"}",
        "event: message\r\ndata:   {\"trace_id\":\"t-crlf\",\"sequence\":4,\"content\":\"crlf\"}\r",
    ]

    let decoder = JSONDecoder()
    let framesMatch = corpus.allSatisfy { frame in
        dispatchAtlasAiStreamFrame(frame) == dispatchAtlasAiStreamFrame(Data(frame.utf8), decoder: decoder)
    }
    check("dispatch Data == dispatch String no corpus existente", framesMatch)
}
