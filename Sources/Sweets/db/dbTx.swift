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
        
        public func commit() async throws {
            if isDone { throw BasicError("Invalid commit") }
            try cx.popTx(self)

            if let sp = savepoint {
                try await cx.exec("RELEASE SAVEPOINT \(sp)")                
            } else {
                try await cx.exec("COMMIT")
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
                try await cx.exec("ROLLBACK TO SAVEPOINT \(sp)")                
            } else {
                try await cx.exec("ROLLBACK")
            }

            isDone = true
        }
    }
}
