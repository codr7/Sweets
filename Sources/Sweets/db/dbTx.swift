import PostgresNIO

extension db {
    public typealias Encodable = PostgresDynamicTypeEncodable & Equatable

    public class Tx: ValueStore {
        public static func ==(_ left: Tx, _ right: Tx) -> Bool {
            ObjectIdentifier(left) == ObjectIdentifier(right)
        }

        public static func !=(_ left: Tx, _ right: Tx) -> Bool {
            ObjectIdentifier(left) != ObjectIdentifier(right)
        }

        let cx: Cx
        let savepoint: String?
        var isDone = false
        
        public init(_ cx: Cx, _ savepoint: String? = nil) {
            self.cx = cx
            self.savepoint = savepoint
        }

        public func exec(_ sql: String, _ params: [any Encodable] = []) async throws {
            let psql = convertParams(sql)
            print("\(psql)\n")
            var bs = PostgresBindings()
            for p in params { bs.append(p) }
            try await cx.connection!.query(PostgresQuery(unsafeSQL: psql, binds: bs), logger: cx.log)
        }

        public func query(_ sql: String, _ params: [any Encodable] = []) async throws {
            let psql = convertParams(sql)
            print("\(psql)\n")
            var bs = PostgresBindings()
            for p in params { bs.append(p) }
            try await cx.connection!.query(PostgresQuery(unsafeSQL: psql, binds: bs), logger: cx.log)
        }

        public func query(_ query: PostgresQuery) async throws -> PostgresRowSequence {
            print("\(query.sql)\n")
            return try await cx.connection!.query(query, logger: cx.log)
        }

        public func queryValue<T: PostgresDecodable>(_ query: PostgresQuery) async throws -> T {
            print("\(query.sql)\n")
            let rows = try await cx.connection!.query(query, logger: cx.log)
            for try await (value) in rows.decode((T).self) { return value }
            throw BasicError("No rows")
        }
        
        public func commit() async throws {
            if isDone { throw BasicError("Invalid commit") }
            try cx.popTx(self)

            if let sp = savepoint {
                try await exec("RELEASE SAVEPOINT \(sp)")                
            } else {
                try await exec("COMMIT")
            }

            moveStoredValues(cx.peekTx() ?? cx)
            isDone = true
        }

        public func moveStoredValues(_ target: ValueStore) {
            for (f, v) in self.storedValues { target[f.record, f.column] = v }
        }
        
        public func rollback() async throws {
            if isDone { throw BasicError("Invalid rollback") }
            try cx.popTx(self)

            if let sp = savepoint {
                try await exec("ROLLBACK TO SAVEPOINT \(sp)")                
            } else {
                try await exec("ROLLBACK")
            }

            isDone = true
        }
    }

    public static func convertParams(_ sql: String) -> String {
        let ss = sql.components(separatedBy: "?")
        var result = ss[0]
        var n = 1
        
        for s in ss[1...] {
            result = result + "$\(n)" + s
            n += 1
        }

        return result
    }
}
