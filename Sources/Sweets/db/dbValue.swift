import PostgresNIO

extension db {
    public typealias ValueId = ObjectIdentifier
    
    public protocol Value {
        var paramSql: String {get}
        var valueId: ValueId {get}
        var valueSql: String {get}
        var valueParams: [any Encodable] {get}
        func encode(_ val: Any) -> any Encodable
    }

    public protocol TypedValue<T>: Value {
        associatedtype T
        func decode(_ value: PostgresCell) throws -> T
    }
    
    public class CustomValue<T: PostgresDecodable>: TypedValue {
        public typealias T = T
        public let valueSql: String
        public let valueParams: [any Encodable]

        public init(_ sql: String, _ params: [any Encodable]) {
            self.valueSql = sql
            self.valueParams = params
        }

        public var valueId: ValueId { ObjectIdentifier(self) }

        public func decode(_ value: PostgresCell) throws -> T { try value.decode(T.self) } 
    }
}

public func ==(_ left: db.Value, _ right: Any) -> db.Condition {
    db.CustomCondition("\(left.valueSql) = \(left.paramSql)", [left.encode(right)])
}

public extension db.Value {
    var paramSql: String { "?" }
    var valueParams: [any db.Encodable] { [] }
    func encode(_ val: Any) -> any db.Encodable { val as! any db.Encodable }

    var EXISTS: any db.TypedValue<Bool> {
        db.CustomValue<Bool>("EXISTS (\(valueSql))", valueParams)
    }
}

public extension [any db.Value] {
    var sql: String { self.map({$0.valueSql}).joined(separator: ", ") }
}

