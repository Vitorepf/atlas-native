import Foundation

/// Aplica o filtro do wrapper `streamAiInteraction`: event/done com trace_id
/// diferente do pedido são descartados; error/ignored passam.
private func emit(
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
    private static let lfDelimiter = Data([0x0A, 0x0A])
    private static let crlfDelimiter = Data([0x0D, 0x0A, 0x0D, 0x0A])

    private let traceId: String
    private let path: String
    private let continuation: AsyncThrowingStream<AtlasAiStreamFrame, Error>.Continuation
    private let decoder = JSONDecoder()
    private var buffer = Data()
    private var finished = false

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

    private func drainCompleteFrames() {
        var cursor = buffer.startIndex
        var consumedEnd: Data.Index?
        while let range = firstDelimiter(in: buffer, from: cursor) {
            let frameData = buffer[cursor..<range.lowerBound]
            dispatch(frameData)
            cursor = range.upperBound
            consumedEnd = range.upperBound
        }
        if let consumedEnd {
            buffer.removeSubrange(..<consumedEnd)
        }
    }

    private func drainRemainder() {
        guard !buffer.isEmpty else { return }
        let remainder = buffer
        buffer.removeAll(keepingCapacity: false)
        dispatch(remainder)
    }

    private func dispatch(_ data: Data) {
        guard !data.isEmpty else { return }
        emit(dispatchAtlasAiStreamFrame(data, decoder: decoder), traceId: traceId, into: continuation)
    }

    private func firstDelimiter(in data: Data, from start: Data.Index) -> Range<Data.Index>? {
        let searchRange = start..<data.endIndex
        let lf = data.range(of: Self.lfDelimiter, options: [], in: searchRange)
        let crlf = data.range(of: Self.crlfDelimiter, options: [], in: searchRange)
        switch (lf, crlf) {
        case (.some(let a), .some(let b)): return a.lowerBound < b.lowerBound ? a : b
        case (.some(let a), .none): return a
        case (.none, .some(let b)): return b
        case (.none, .none): return nil
        }
    }

    private func finish(throwing error: Error? = nil) {
        guard !finished else { return }
        finished = true
        if let error { continuation.finish(throwing: error) }
        else { continuation.finish() }
    }
}
