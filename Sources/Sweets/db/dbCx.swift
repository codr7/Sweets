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

        private func _startTx() async throws -> Tx {
            if txStack.isEmpty {
                let tx = Tx(self)
                try await tx.exec("BEGIN")
                return tx
            }

            let sp = Cx.makeSavepoint()
            let tx = Tx(self, sp)
            try await tx.exec("SAVEPOINT \(sp)")
            return tx
        }
        
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
