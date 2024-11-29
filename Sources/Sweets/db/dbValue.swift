extension db {
    public protocol Value {        
        var paramSql: String {get}
        var valueSql: String {get}
        var valueParams: [any Encodable] {get}
        func encode(_ val: Any) -> any Encodable
    }
}

public func ==(_ left: db.Value, _ right: Any) -> db.Condition {
    db.CustomCondition("\(left.valueSql) = \(left.paramSql)", [left.encode(right)])
}

public extension db.Value {
    var paramSql: String {
        "?"
    }
    
    var valueParams: [any db.Encodable] {
        []
    }
    
    func encode(_ val: Any) -> any db.Encodable {
        val as! any db.Encodable
    }
}

public extension [any db.Value] {
    var sql: String {
        self.map({$0.valueSql}).joined(separator: ", ")
    }
}

