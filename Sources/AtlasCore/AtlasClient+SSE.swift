import Foundation

/// Aplica o filtro do wrapper `streamAiInteraction`: event/done com trace_id
/// diferente do pedido são descartados; error/ignored passam.
func emit(
    _ frame: AtlasAiStreamFrame,
    traceId: String,
    into continuation: AsyncThrowingStream<AtlasAiStreamFrame, Error>.Continuation
) {
    switch frame {
    case .event(let e) where e.traceId != traceId: return
    case .done(let d) where d.traceId != traceId: return
    default: continuation.yield(frame)
    }
}

final class AtlasSSESessionDelegate: NSObject, URLSessionDataDelegate, @unchecked Sendable {
    static let lfDelimiter = Data([0x0A, 0x0A])
    static let crlfDelimiter = Data([0x0D, 0x0A, 0x0D, 0x0A])

    let traceId: String
    let path: String
    let continuation: AsyncThrowingStream<AtlasAiStreamFrame, Error>.Continuation
    let decoder = JSONDecoder()
    var buffer = Data()
    var finished = false

    init(
        traceId: String,
        path: String,
        continuation: AsyncThrowingStream<AtlasAiStreamFrame, Error>.Continuation
    ) {
        self.traceId = traceId
        self.path = path
        self.continuation = continuation
    }

    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping (URLSession.ResponseDisposition) -> Void
    ) {
        let status = (response as? HTTPURLResponse)?.statusCode ?? 0
        guard (200..<300).contains(status) else {
            finish(throwing: AtlasApiError(status: status, path: path, message: "Atlas stream \(status)"))
            completionHandler(.cancel)
            return
        }
        completionHandler(.allow)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard !finished else { return }
        buffer.append(data)
        drainCompleteFrames()
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard !finished else { return }
        if let error {
            if (error as? URLError)?.code == .cancelled { finish() }
            else { finish(throwing: error) }
            return
        }
        drainRemainder()
        finish()
    }
}
