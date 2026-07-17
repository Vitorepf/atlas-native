import Foundation

/// HTTP transport peel — `getData` + keyed decode request (régua ~100).
extension AtlasClient {
    public func getData(_ path: String, auth: Bool = true, timeout: TimeInterval = 15) async throws -> AtlasRawDataResponse {
        let timeout = adjustedTimeout(timeout)
        guard let url = URL(string: config.base + path) else {
            throw AtlasApiError(status: 0, path: path, message: "URL inválida")
        }
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.timeoutInterval = timeout
        req.setValue("*/*", forHTTPHeaderField: "Accept")
        if auth { req.setValue(config.token, forHTTPHeaderField: "X-Atlas-Token") }

        let (data, response) = try await session.data(for: req)
        let http = response as? HTTPURLResponse
        let status = http?.statusCode ?? 0
        guard (200..<300).contains(status) else {
            throw AtlasApiError(
                status: status,
                path: path,
                message: Self.errorMessage(data) ?? "HTTP \(status)",
                retryAfterSeconds: Self.retryAfterSeconds(from: http)
            )
        }

        return AtlasRawDataResponse(
            data: data,
            status: status,
            contentType: http?.value(forHTTPHeaderField: "Content-Type") ?? "application/octet-stream",
            atlasSha256: http?.value(forHTTPHeaderField: "X-Atlas-Sha256")
        )
    }

    func request<T: Decodable>(_ path: String, method: String, body: Data?, auth: Bool, timeout: TimeInterval = 15) async throws -> T {
        let timeout = adjustedTimeout(timeout)
        guard let url = URL(string: config.base + path) else {
            throw AtlasApiError(status: 0, path: path, message: "URL inválida")
        }
        var req = URLRequest(url: url)
        req.httpMethod = method
        req.timeoutInterval = timeout
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        if auth { req.setValue(config.token, forHTTPHeaderField: "X-Atlas-Token") }
        if let body {
            req.httpBody = body
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        let (data, response) = try await session.data(for: req)
        let http = response as? HTTPURLResponse
        let status = http?.statusCode ?? 0
        guard (200..<300).contains(status) else {
            throw AtlasApiError(
                status: status,
                path: path,
                message: Self.errorMessage(data) ?? "HTTP \(status)",
                retryAfterSeconds: Self.retryAfterSeconds(from: http)
            )
        }
        return try decoder.decode(T.self, from: data)
    }
}
