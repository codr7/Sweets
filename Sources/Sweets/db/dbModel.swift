extension db {
    public typealias Model = IModel & BasicModel

    public protocol IModel {
        var cx: Cx {get}
        var record: Record {get}
        var tables: [Table] {get}
    }
    
    open class BasicModel {
        public let cx: Cx
        public let record: Record
        
        public init(_ cx: Cx, _ record: Record? = nil) {
            self.cx = cx
            self.record = record ?? Record()
        }
    }
}

public extension db.IModel {
    var isModified: Bool {
        let tx = (cx.peekTx() ?? cx)
        
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
    func store() async throws -> db.IModel {
        for t in tables { try await t.store(record, cx) }
        return self
    }
}

