import Foundation
import PostgresNIO

extension db {
    public typealias Column<T> = BasicColumn<T> & IColumn where T: Equatable & PostgresDecodable
    
    public protocol IColumn: Value, ITableDefinition {
        var columnType: String {get}
        var defaultValue: Any? {get}
        var id: ObjectIdentifier {get}
        var isNullable: Bool {get}
        var isPrimaryKey: Bool {get}
        
        func clone(_ name: String, _ table: Table,
                   isNullable: Bool, isPrimaryKey: Bool) -> IColumn
        
        func equalValues(_ left: Any, _ right: Any) -> Bool
    }

    public class BasicColumn<T: Equatable & PostgresDecodable>:
      BasicTableDefinition, TypedValue {
        public typealias T = T
        public let defaultValue: Any?
        public let isNullable: Bool
        public let isPrimaryKey: Bool
        
        public init(_ name: String, _ table: Table,
                    defaultValue: Any? = nil,
                    isNullable: Bool = false, isPrimaryKey: Bool = false) {
            self.defaultValue = defaultValue
            self.isNullable = isNullable
            self.isPrimaryKey = isPrimaryKey
            super.init(name, table)
        }
        
        public let definitionType = "COLUMN"        
        public var id: ObjectIdentifier { ObjectIdentifier(self) }
        public var paramSql: String { "?" }
        public func encode(_ value: Any) -> any Encodable { value as! any Encodable }

        public func equalValues(_ left: Any, _ right: Any) -> Bool {
            return left as! T == right as! T
        }
        
        public func exists(_ cx: Cx) async throws -> Bool {
            try await cx.queryValue("""
                                      SELECT EXISTS (
                                      SELECT
                                      FROM pg_attribute 
                                      WHERE attrelid = \(table.name)::regclass
                                      AND attname = \(name)
                                      AND NOT attisdropped
                                      )
                                      """)
        }

        public var valueId: ValueId { ObjectIdentifier(self) }
        public var valueParams: [any Encodable] { [] }
        public var valueSql: String { "\(table.nameSql).\(nameSql)" }
    }

    public class BoolColumn: Column<Bool> {
        public init(_ name: String, _ table: Table,
                    defaultValue: Bool? = false,
                    isNullable: Bool = false, isPrimaryKey: Bool = false) {
            super.init(name, table,
                       defaultValue: defaultValue,
                       isNullable: isNullable, isPrimaryKey: isPrimaryKey)
            
            table.definitions.append(self)
            table._columns.append(self)
        }
        
        public let columnType = "BOOLEAN"

        public func clone(_ name: String, _ table: Table,
                          isNullable: Bool, isPrimaryKey: Bool) -> IColumn {
            BoolColumn(name, table,
                       isNullable: isNullable, isPrimaryKey: isPrimaryKey)
        }
    }

    public class DateColumn: Column<Date> {
        public static let minValue = Date(timeIntervalSince1970: 0)
        
        public init(_ name: String, _ table: Table,
                    defaultValue: Date? = minValue,
                    isNullable: Bool = false, isPrimaryKey: Bool = false) {
            super.init(name, table,
                       defaultValue: defaultValue,
                       isNullable: isNullable, isPrimaryKey: isPrimaryKey)
            table.definitions.append(self)
            table._columns.append(self)
        }

        public let columnType = "TIMESTAMPTZ"

        public func clone(_ name: String, _ table: Table,
                          isNullable: Bool, isPrimaryKey: Bool) -> IColumn {
            DateColumn(name, table,
                       isNullable: isNullable, isPrimaryKey: isPrimaryKey)
        }
    }

    public class DecimalColumn: Column<Decimal> {
        let precision: Int
        
        public init(_ name: String, _ table: Table,
                    defaultValue: Decimal? = Decimal(0),
                    isNullable: Bool = false, isPrimaryKey: Bool = false,
                    precision: Int = 38) {
            self.precision = precision
            
            super.init(name, table,
                       defaultValue: defaultValue,
                       isNullable: isNullable, isPrimaryKey: isPrimaryKey)
            
            table.definitions.append(self)
            table._columns.append(self)
        }

        public var columnType: String { "DECIMAL(\(precision))" }

        public func clone(_ name: String, _ table: Table,
                          isNullable: Bool, isPrimaryKey: Bool) -> IColumn {
            DecimalColumn(name, table,
                          isNullable: isNullable,
                          isPrimaryKey: isPrimaryKey,
                          precision: precision)
        }
    }

    public class EnumColumn<T: Enum>: Column<T> where T.RawValue == String {
        public let type: EnumType<T>

        public init(_ name: String, _ table: Table,
                             defaultValue: T? = nil,
                             isNullable: Bool = false, isPrimaryKey: Bool = false) {
            type = EnumType<T>()

            super.init(name, table,
                       defaultValue: defaultValue,
                       isNullable: isNullable, isPrimaryKey: isPrimaryKey)
            
            table.definitions.append(self)
            table._columns.append(self)
        }

        public var columnType: String { "\"\(String(describing: T.self))\"" }

        public override var paramSql: String { "?::\(type.nameSql)" }
        
        public func clone(_ name: String, _ table: Table,
                          isNullable: Bool, isPrimaryKey: Bool ) -> IColumn {
            EnumColumn<T>(name, table,
                          isNullable: isNullable, isPrimaryKey: isPrimaryKey)
        }

        public func create(_ cx: Cx) async throws {
            if !(try await type.exists(cx)) {
                try await type.create(cx)
            }
            
            try await cx.exec(self.createSql)
        }

        public override func encode(_ value: Any) -> any Encodable {
            (value as! T).rawValue
        }

        public func sync(_ cx: Cx) async throws {
            try await type.sync(cx)
            if !(try await exists(cx)) { try await create(cx) }
        }
    }
    
    public class IdColumn: Column<Sequence.Value> {
        public init(_ name: String, _ table: Table,
                             defaultValue: Int? = nil,
                             isNullable: Bool = false, isPrimaryKey: Bool = false) {
            super.init(name, table,
                       defaultValue: defaultValue,
                       isNullable: isNullable, isPrimaryKey: isPrimaryKey)
            
            table.definitions.append(self)
            table._columns.append(self)
        }
        
        public let columnType = "BIGSERIAL"

        public func clone(_ name: String, _ table: Table,
                          isNullable: Bool, isPrimaryKey: Bool) -> IColumn {
            IdColumn(name, table,
                     isNullable: isNullable, isPrimaryKey: isPrimaryKey)
        }
    }

    
    public class IntColumn: Column<Int> {
        public init(_ name: String, _ table: Table,
                    defaultValue: Int? = 0,
                    isNullable: Bool = false, isPrimaryKey: Bool = false) {
            super.init(name, table,
                       defaultValue: defaultValue,
                       isNullable: isNullable, isPrimaryKey: isPrimaryKey)
            table.definitions.append(self)
            table._columns.append(self)
        }

        public let columnType = "INTEGER"

        public func clone(_ name: String, _ table: Table,
                          isNullable: Bool, isPrimaryKey: Bool) -> IColumn {
            IntColumn(name, table,
                      isNullable: isNullable, isPrimaryKey: isPrimaryKey)
        }
    }

    public class StringColumn: Column<String> {
        public init(_ name: String, _ table: Table,
                    defaultValue: String? =  "",
                    isNullable: Bool = false, isPrimaryKey: Bool = false) {
            super.init(name, table,
                       defaultValue: defaultValue,
                       isNullable: isNullable, isPrimaryKey: isPrimaryKey)
            
            table.definitions.append(self)
            table._columns.append(self)
        }

        public let columnType = "TEXT"

        public func clone(_ name: String, _ table: Table,
                          isNullable: Bool, isPrimaryKey: Bool ) -> IColumn {
            StringColumn(name, table,
                         isNullable: isNullable, isPrimaryKey: isPrimaryKey)
        }
    }

}

public extension db.IColumn {
    var createSql: String {
        var sql = "\(db.createSql(self as db.ITableDefinition)) \(columnType)"
        if isPrimaryKey || !isNullable { sql += " NOT NULL" }
        return sql
    }

    var dropSql: String { db.dropSql(self) }
}

extension [any db.IColumn] {
    var sql: String {
        self.map({$0.nameSql}).joined(separator: ", ")
    }
}

extension Decimal: @retroactive PostgresDynamicTypeEncodable {}
extension UInt64: @retroactive PostgresDecodable {}
