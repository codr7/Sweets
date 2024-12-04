import PostgresNIO

extension db {
    public class Query: Condition, Value {
        public class Result {
            public let cx: Cx
            public let query: Query
            private var rows: PostgresRowSequence.AsyncIterator
            private var row: PostgresRandomAccessRow?
            
            public init(_ cx: Cx,
                        _ query: Query,
                        _ rows: PostgresRowSequence.AsyncIterator) {
                self.cx = cx
                self.query = query
                self.rows = rows
            }

            public subscript<T>(value: any TypedValue<T>) -> T? {
                get {
                    if let i = query.valueLookup[value.valueId] {
                        try! value.decode(row![i]) as! T
                    }
                    else { nil }
                }
            }

            public subscript(value: any Value) -> Any? {
                get {
                    if let i = query.valueLookup[value.valueId] {
                        try! value.decode(row![i])
                    } else { nil }
                }
            }

            public func fetch() async throws -> Bool {
                row = if let r = try await rows.next() { PostgresRandomAccessRow(r) }
                  else { nil }
                
                return row != nil
            }
        }
        
        var conditions: [Condition] = []
        var limit: Int?
        var sources: [Source] = []
        var valueLookup: [ValueId:Int] = [:]
        var values: [Value] = []

        public init() {}
        public var conditionParams: [any Encodable] { params }
        public var conditionSql: String { sql }

        public var params: [any Encodable] {
            var out: [any Encodable] = []

            for v in values {
                out += v.valueParams
            }
            
            for s in sources {
                out += s.sourceParams
            }

            for c in conditions {
                out += c.conditionParams
            }

            return out
        }

        public var sql: String {
            var s = "SELECT \(values.isEmpty ? "NULL" : values.sql)" 
            if !sources.isEmpty { s += " FROM \(sources.sql)" }

            if !conditions.isEmpty {
                s += " WHERE \(foldAnd(conditions).conditionSql)"
            }

            if let v = limit { s += " LIMIT \(v)" }
            return s
        }

        public var valueId: ValueId { ObjectIdentifier(self) }
        public var valueParams: [any Encodable] { params }
        public var valueSql: String { sql }

        public func exec(_ cx: Cx) async throws -> Result {
            let rows = try await cx.queryRows(valueSql, valueParams)
            return Result(cx, self, rows.makeAsyncIterator())
        }

        public func FROM(_ args: Source...) -> Query {
            for s in args { sources.append(s) }
            return self
        }

        public func LIMIT(_ value: Int?) -> Query {
            limit = value
            return self
        }
        
        public func SELECT(_ args: [Value]) -> Query {
            for v in args {
                valueLookup[v.valueId] = values.count
                values.append(v)
            }
            
            return self
        }

        public func SELECT(_ args: Value...) -> Query { SELECT(args) }

        public func WHERE(_ args: Condition...) -> Query {
            for c in args { conditions.append(c) }
            return self
        }
    }
}
