extension db {
    public class Schema {
        var definitions: [Definition] = []

        public init() {}
        
        public func create(_ cx: Cx) async throws {
            for d in definitions { try await d.create(cx) }
        }
        
        public func drop(_ cx: Cx) async throws {
            for d in definitions { try await d.drop(cx) }
        }
        
        public func sync(_ cx: Cx) async throws {
            for d in definitions { try await d.sync(cx) }
        }
    }
}
