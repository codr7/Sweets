extension db {
    public typealias Model = IModel & BasicModel

    public protocol IModel {
        var db: Cx {get}
        var record: Record {get set}
        var tables: [Table] {get}
    }
    
    open class BasicModel {
        public let db: Cx
        public var record: Record
        
        public init(_ db: Cx, _ record: Record? = nil) {
            self.db = db
            self.record = record ?? Record()
        }
    }
}

public extension db.IModel {
    var isModified: Bool {
        let tx = (db.peekTx() ?? db)
        
        return tables.contains(
          where: {t in
                   t.columns.contains(
                     where: {c in
                              let v = record[c]
                              let sv = tx[record, c]
                              return (v == nil && sv != nil) ||
                                (v != nil && sv == nil) ||
                                !c.equalValues(v!, sv!)
                          })
               })
    }

    @discardableResult
    mutating func store() async throws -> db.IModel {
        for t in tables { try await t.store(&record, db) }
        return self
    }
}

