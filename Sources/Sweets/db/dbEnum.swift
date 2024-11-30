import PostgresNIO

extension db {
    public protocol Enum: CaseIterable, Equatable, RawRepresentable
      where RawValue == String {
    }

    public class EnumType<T: Enum>: Definition {
        public init(_ schema: Schema) {
            super.init(schema, String(describing: T.self))
        }
        
        public var createSql: String {
            "\(db.createSql(self as Definition)) AS ENUM ()"
        }

        public let definitionType = "TYPE"

        public var dropSql: String { db.dropSql(self) }
        
        public func create(_ cx: Cx) async throws {
            try await cx.exec(self.createSql)

            for m in T.allCases {
                try await EnumMember(self, m.rawValue).create(cx)
            }
        }

        public func exists(_ cx: Cx) async throws -> Bool {
            try await cx.queryValue("""
                                      SELECT EXISTS (
                                      SELECT FROM pg_type
                                      WHERE typname  = \(name)
                                      )
                                      """)
        }    

        public func sync(_ cx: Cx) async throws {        
            if (try await exists(cx)) {
                for m in T.allCases {
                    try await EnumMember<T>(self, m.rawValue).sync(cx)
                }
            } else {
                try await create(cx)
            }
        }
    }

    public class EnumMember<T: Enum>: Definition {
        let type: EnumType<T>
        
        public init(_ type: EnumType<T>, _ name: String) {
            self.type = type
            super.init(type.schema, name)
        }

        public var definitionType = "VALUE"
        
        public var createSql: String {
            "ALTER TYPE \(type.nameSql) ADD VALUE '\(name)'"
        }
        
        public var dropSql: String {
            "ALTER TYPE \(type.nameSql) DROP VALUE '\(name)'"
        }

        public func exists(_ cx: Cx) async throws -> Bool {
            try await cx.queryValue(
              """
                SELECT EXISTS (
                SELECT
                FROM pg_type t 
                JOIN pg_enum e on e.enumtypid = t.oid  
                JOIN pg_catalog.pg_namespace n ON n.oid = t.typnamespace
                WHERE t.typname = \(type.name) AND e.enumlabel = \(name)
                )
                """)
        }
    }
}
