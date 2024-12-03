import PostgresNIO

extension db {
    public class Sequence: Definition {
        public typealias Value = Int
        public let start: Value
        
        public init(_ name: String, _ start: Int = 0) {
            self.start = Value(start)
            super.init(name)
        }
        
        public var createSql: String {
            "\(db.createSql(self as Definition)) START \(start)"
        }

        public let definitionType = "SEQUENCE"

        public var dropSql: String { db.dropSql(self) }
        
        public func exists(_ cx: Cx) async throws -> Bool {
            try await cx.queryValue("""
                                      SELECT EXISTS (
                                      SELECT FROM pg_class
                                      WHERE relkind='s'
                                      AND relname='\(name)'
                                      )
                                      """)
        }

        public func next(_ cx: Cx) async throws -> Value {
            print("name: \(name)")
            return try await cx.queryValue("SELECT NEXTVAL('\"\(name)\"')", [])
        }
    }
}
