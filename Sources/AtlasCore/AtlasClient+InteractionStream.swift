import Foundation

/// Stream SSE + steer de interação — peel do shell AtlasClient.
extension AtlasClient {
    // MARK: - Live SSE stream (transporte de `streamAiInteraction`)

    /// Abre o stream de uma interação e emite frames tipados conforme chegam.
    /// `URLSession.bytes.lines` já faz o framing SSE (linha em branco = fim de
    /// frame). Filtra por traceId como o wrapper do .ts. ponytail: conexão
    /// única; reconnect+backoff (maxReconnects=4 no .ts) é o upgrade de
    /// resiliência quando o SSE cair em runs longas.
    public func streamInteraction(
        traceId: String,
        after: Int = 0,
        timeoutSeconds: Int = 120,
        maxReconnects: Int = 4
    ) -> AsyncThrowingStream<AtlasAiStreamFrame, Error> {
        makeAtlasResumableInteractionStream(
            source: self,
            traceId: traceId,
            after: after,
            timeoutSeconds: timeoutSeconds,
            policy: AtlasStreamReconnectPolicy(maxReconnects: maxReconnects)
        )
    }

    public func openInteractionStreamOnce(
        traceId: String,
        after: Int,
        timeoutSeconds: Int
    ) async throws -> AsyncThrowingStream<AtlasAiStreamFrame, Error> {
        let cfg = config
        let adjustedWindow = Int(adjustedTimeout(TimeInterval(timeoutSeconds)).rounded(.up))
        return AsyncThrowingStream { continuation in
            let timeout = min(max(adjustedWindow, 5), 600)
            let cursor = max(0, after)
            let path = AtlasRoute.aiInteractionStream(traceId, timeout: timeout, after: cursor)
            guard let url = URL(string: cfg.base + path) else {
                continuation.finish(throwing: AtlasApiError(status: 0, path: path, message: "URL inválida"))
                return
            }

            var request = URLRequest(url: url)
            request.timeoutInterval = TimeInterval(timeout + 15)
            request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
            request.setValue(cfg.token, forHTTPHeaderField: "X-Atlas-Token")

            // `URLSession.bytes.lines` devolveu corpo vazio contra o stream PHP
            // real no device/macOS, embora curl recebesse os frames. O delegate
            // é o caminho nativo realmente incremental: cada `didReceive data`
            // alimenta o framing SSE sem esperar a resposta terminar.
            let delegate = AtlasSSESessionDelegate(
                traceId: traceId,
                path: path,
                continuation: continuation
            )
            let queue = OperationQueue()
            queue.maxConcurrentOperationCount = 1
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = TimeInterval(timeout + 15)
            configuration.timeoutIntervalForResource = TimeInterval(timeout + 15)
            let streamSession = URLSession(configuration: configuration, delegate: delegate, delegateQueue: queue)
            let task = streamSession.dataTask(with: request)
            continuation.onTermination = { _ in
                task.cancel()
                streamSession.invalidateAndCancel()
                _ = delegate
            }
            task.resume()
        }
    }

    /// M07 · Steer de uma execução viva. O contrato publica tanto o aceite 202
    /// quanto a rejeição governada 422 no mesmo schema, então este caminho
    /// decodifica ambos e só transforma outros HTTP em `AtlasApiError`.
    /// (Fica no core: precisa de config/session/encoder/decoder privados.)
    public func steerAiInteraction(
        _ id: String,
        input: AtlasInteractionSteerInput
    ) async throws -> AtlasInteractionSteerResponse {
        let path = AtlasRoute.aiInteractionSteer(id)
        guard let url = URL(string: config.base + path) else {
            throw AtlasApiError(status: 0, path: path, message: "URL inválida")
        }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.timeoutInterval = 15
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue(config.token, forHTTPHeaderField: "X-Atlas-Token")
        req.httpBody = try encoder.encode(input)
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await session.data(for: req)
        let status = (response as? HTTPURLResponse)?.statusCode ?? 0
        guard status == 202 || status == 422 else {
            throw AtlasApiError(status: status, path: path, message: Self.errorMessage(data) ?? "HTTP \(status)")
        }
        return try decoder.decode(AtlasInteractionSteerResponse.self, from: data)
    }
}
