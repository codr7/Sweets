extension db {
    open class Schema {
        var definitions: [Definition] = []

        public init() {}
                
        public func create(_ cx: Cx) async throws {
            for d in definitions { try await d.create(cx) }
        }
        
        public func drop(_ cx: Cx) async throws {
            for d in definitions { try await d.drop(cx) }
        }

        public func register(_ definitions: Definition...) {
            for d in definitions { self.definitions.append(d) }
        }

        public func sync(_ cx: Cx) async throws {
            for d in definitions { try await d.sync(cx) }
        }
    }
}
