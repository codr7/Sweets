import Foundation
import PostgresNIO

extension db {
    public class Cx: ValueStore {
        public static func makeSavepoint() -> String {
            "SP\(String(UUID().description.filter({$0 != "-"})))"
        }
        
        let host: String
        let port: Int
        let database: String
        let user: String
        let password: String
        
        let log: Logger
        var connection: PostgresConnection?
        var txStack: [Tx] = []
        
        public init(host: String = "localhost", port: Int = 5432,
                    database: String,
                    user: String, password: String) {
            self.host = host
            self.port = port
            self.database = database
            self.user = user
            self.password = password
            log = Logger(label: "postgres")
        }

        public func connect() async throws {
            let config = PostgresConnection.Configuration(
              host: host,
              port: port,
              username: user,
              password: password,
              database: database,
              tls: .disable
            )

            connection = try await PostgresConnection.connect(
              configuration: config,
              id: 1,
              logger: log
            )
        }
        
        public func disconnect() async throws {
            try await connection!.close()
            connection = nil
        }

        public func exec(_ sql: String, _ params: [any Encodable] = []) async throws {
            let psql = convertParams(sql)
            print("\(psql)\n")
            var bs = PostgresBindings()
            for p in params { bs.append(p) }
            try await connection!.query(PostgresQuery(unsafeSQL: psql, binds: bs), logger: log)
        }

        public func query(_ sql: String, _ params: [any Encodable] = []) async throws {
            let psql = convertParams(sql)
            print("\(psql)\n")
            var bs = PostgresBindings()
            for p in params { bs.append(p) }
            try await connection!.query(PostgresQuery(unsafeSQL: psql, binds: bs), logger: log)
        }

        public func query(_ query: PostgresQuery) async throws -> PostgresRowSequence {
            print("\(query.sql)\n")
            return try await connection!.query(query, logger: log)
        }

        public func queryValue<T: PostgresDecodable>(_ query: PostgresQuery) async throws -> T {
            print("\(query.sql)\n")
            let rows = try await connection!.query(query, logger: log)
            for try await (value) in rows.decode((T).self) { return value }
            throw BasicError("No rows")
        }

        private func _startTx() async throws -> Tx {
            if txStack.isEmpty {
                let tx = Tx(self)
                try await exec("BEGIN")
                return tx
            }

            let sp = Cx.makeSavepoint()
            let tx = Tx(self, sp)
            try await exec("SAVEPOINT \(sp)")
            return tx
        }

        @discardableResult
        public func startTx() async throws -> Tx {
            let tx = try await _startTx()
            txStack.append(tx)
            return tx
        }

        public func peekTx() -> Tx? { txStack.isEmpty ? nil : txStack.last! }

        public func popTx(_ tx: Tx) throws {
            if txStack.removeLast() != tx { throw BasicError("Invalid tx") }
        }
    }
}
