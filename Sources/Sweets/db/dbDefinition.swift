extension db {
    public typealias Definition = BasicDefinition & IDefinition
    
    public protocol IDefinition {
        var createSql: String {get}
        var definitionType: String {get}
        var dropSql: String {get}
        var name: String {get}
        var nameSql: String {get}
        
        func create(_ cx: Cx) async throws
        func drop(_ cx: Cx) async throws
        func sync(_ cx: Cx) async throws
        func exists(_ cx: Cx) async throws -> Bool
    }

    public class BasicDefinition {
        public let name: String
        
        public init(_ name: String) {
            self.name = name
        }

        public var nameSql: String { "\"\(name)\"" }
    }

    public static func createSql(_ d: IDefinition) -> String {
        "CREATE \(d.definitionType) IF NOT EXISTS \(d.nameSql)"
    }

    public static func dropSql(_ d: IDefinition) -> String {
        "DROP \(d.definitionType) IF EXISTS \(d.nameSql)"
    }
}

public extension db.IDefinition {
    func create(_ cx: db.Cx) async throws { try await cx.exec(self.createSql) }
    func drop(_ cx: db.Cx) async throws { try await cx.exec(self.dropSql) }

    func sync(_ cx: db.Cx) async throws {
        if !(try await exists(cx)) { try await create(cx) }
    }
}
