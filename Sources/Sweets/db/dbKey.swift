extension db {
    public class Key: Constraint {
        public override init(_ name: String, _ columns: [IColumn]) {
            super.init(name, columns)
            self.table.definitions.append(self)
        }
        
        public var constraintType: String {
            if self === table.primaryKey {
                "PRIMARY KEY"
            } else {
                "UNIQUE"
            }
        }

        public var createSql: String { db.createSql(self) }        
        public var dropSql: String { db.dropSql(self) }   
    }
}

public func ==(_ left: db.Key, _ right: db.Record) throws -> db.Condition {
    db.foldOr(try left.columns.map(
                {c in
                    if let v = right[c] { c == v }
                    else { throw db.BasicError("Missing key: \(c)") }
                }))
}
