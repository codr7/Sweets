import FlyingFox

extension http {
    public static func start() async throws {
        let server = HTTPServer(port: 8080)
        try await server.run()
    }
}
