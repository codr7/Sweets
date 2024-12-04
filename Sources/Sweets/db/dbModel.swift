extension db {
    public typealias Model = IModel & BasicModel

    public protocol IModel {
        var dbCx: Cx {get}
        var record: Record {get set}
        var tables: [Table] {get}
    }
    
    open class BasicModel {
        public let dbCx: Cx
        public var record: Record
        
        public init(_ dbCx: Cx, _ record: Record? = nil) {
            self.dbCx = dbCx
            self.record = record ?? Record()
        }
    }
}

public extension db.IModel {
    var isModified: Bool {
        let tx = (dbCx.peekTx() ?? dbCx)
        
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
        for t in tables { try await t.store(&record, dbCx) }
        return self
    }
}

