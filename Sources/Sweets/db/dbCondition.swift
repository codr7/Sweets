extension db {
    public protocol Condition {
        var conditionSql: String {get}
        var conditionParams: [any Encodable] {get}
    }

    public struct CustomCondition: Condition {
        public let conditionSql: String
        public let conditionParams: [any Encodable]

        public init(_ sql: String, _ params: [any Encodable]) {
            self.conditionSql = sql
            self.conditionParams = params
        }
    }

    public static func foldAnd(_ conds: [Condition]) -> Condition {
        conds[1...].reduce(conds[0], {$0 || $1})
    }

    public static func foldOr(_ conds: [Condition]) -> Condition {
        conds[1...].reduce(conds[0], {$0 || $1})
    }
}

public func &&(_ left: db.Condition, _ right: db.Condition) -> db.Condition {
    db.CustomCondition("(\(left.conditionSql)) AND (\(right.conditionSql))",
                       left.conditionParams + right.conditionParams)
}

public func ||(_ left: db.Condition, _ right: db.Condition) -> db.Condition {
    db.CustomCondition("(\(left.conditionSql)) OR (\(right.conditionSql))",
                       left.conditionParams + right.conditionParams)
}
