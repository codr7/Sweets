extension db {
    public class Table: Definition, Source {
        var definitions: [any TableDefinition] = []
        var _columns: [IColumn] = []
        public var columns: [IColumn] { _columns }
        var foreignKeys: [ForeignKey] = []
        lazy var primaryKey: Key = Key("\(name)PrimaryKey", _columns.filter {$0.isPrimaryKey})
        public var sourceSql: String { nameSql }

        public override init(_ name: String) {
            super.init(name)
        }
        
        public var createSql: String { "\(db.createSql(self)) ()" }
        public let definitionType = "TABLE"
        public var dropSql: String { db.dropSql(self) }

        public func create(_ cx: Cx) async throws {
            try await cx.exec(createSql)
            _ = primaryKey
            for d in definitions {try await d.create(cx)}
        }

        public func exists(_ cx: Cx) async throws -> Bool {
            try await cx.queryValue("""
                                      SELECT EXISTS (
                                      SELECT FROM pg_tables
                                      WHERE tablename  = \(name)
                                      )
                                      """)
        }

        public func insert(_ rec: Record, _ cx: Cx) async throws {
            let cvs = _columns.map({($0, rec[$0])}).filter({$0.1 != nil})

            let sql = """
              INSERT INTO \(nameSql) (\(cvs.map({$0.0}).sql))
              VALUES (\(cvs.map({$0.0.paramSql}).joined(separator: ", ")))
              """

            try await cx.exec(sql, cvs.map {$0.0.encode($0.1!)})
            let tx = cx.peekTx()!
            for cv in cvs { tx[rec, cv.0] = cv.1 }
        }

        public func update(_ rec: Record, _ cx: Cx) async throws {
            let cvs = _columns.map({($0, rec[$0])}).filter({$0.1 != nil})
            var wcs: [Condition] = []

            for c in primaryKey.columns {
                let v = cx[rec, c] ?? rec[c]
                if v == nil { throw BasicError("Missing key: \(c)") }
                wcs.append(c == v!)
            }
            
            let w = foldAnd(wcs)
            
            let sql = """
              UPDATE \(nameSql)
              SET \(cvs.map({"\($0.0.nameSql) = \($0.0.paramSql)"}).joined(separator: ", "))
              WHERE \(w.conditionSql)
              """

            try await cx.exec(sql, cvs.map({$0.0.encode($0.1!)}) + w.conditionParams)
            let tx = cx.peekTx()!
            for cv in cvs {tx[rec, cv.0] = cv.1}
        }

        public func store(_ rec: Record, _ cx: Cx) async throws {
            if rec.isStored(_columns, cx) { try await update(rec, cx) }
            else { try await insert(rec, cx) }
        }

        public func sync(_ cx: Cx) async throws {
            if (try await exists(cx)) {
                for d in definitions { try await d.sync(cx) }
            } else {
                try await create(cx)
            }
        }
    }
}
