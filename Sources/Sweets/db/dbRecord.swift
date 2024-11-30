extension db {
    public typealias Field = (IColumn, Any)

    public class Record {
        public var fields: [Field] {_fields.items}
        
        var _fields = OrderedSet({(l: IColumn, r: Field) -> Order in
                                     let t = compare(ObjectIdentifier(l.table),
                                                     ObjectIdentifier(r.0.table))
                                     
                                     return if t == .equal {
                                         compare(l.id, r.0.id)
                                     } else {
                                         t
                                     }   
                                 })

        public init() {}

        public var count: Int { _fields.count }

        public subscript<T>(column: Column<T>) -> T? {
            get {
                if let f = _fields[column] { (f.1 as! T) } else { nil }
            }
            set(value) {
                if value == nil {
                    _fields[column] = nil
                } else {
                    _fields[column] = (column, value!)
                }
            }
        }

        public subscript(column: IColumn) -> Any? {
            get {
                if let f = _fields[column] { f.1 } else { nil }
            }
            set(value) {
                if value == nil {
                    _fields[column] = nil
                } else {
                    _fields[column] = (column, value!)
                }
            }
        }

        public subscript(key: ForeignKey) -> Record {
            get {
                let result = Record()
                
                for i in 0..<key.columns.count {
                    if let v = _fields[key.columns[i]] {
                        result[key.foreignColumns[i]] = v
                    }
                }

                return result
            }
            set(source) {
                for i in 0..<key.columns.count {
                    _fields[key.columns[i]] = source._fields[key.foreignColumns[i]]
                }
            }
        }

        public func isModified(_ columns: [IColumn], _ cx: Cx) -> Bool {
            let tx = (cx.peekTx() ?? cx)

            for c in columns {
                let l = self[c]
                let r = tx[self, c]
                if l == nil && r == nil  { continue }
                if l == nil || r == nil || !c.equalValues(l!, r!) { return true }
            }

            return false
        }

        public func isStored(_ columns: [IColumn], _ cx: Cx) -> Bool {
            let tx = (cx.peekTx() ?? cx)
            return columns.contains(where: {tx[self, $0] != nil})
        }
    }
}
