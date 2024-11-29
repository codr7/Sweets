extension db {
    struct ValueKey: Hashable {
        public static func ==(l: ValueKey, r: ValueKey) -> Bool {
            l.record === r.record && l.column.id == r.column.id
        }
        
        let record: Record
        let column: any IColumn
        
        init(_ record: Record, _ column: any IColumn) {
            self.record = record
            self.column = column
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(ObjectIdentifier(record))
            hasher.combine(column.id)
        }
    }

    public class ValueStore {
        var storedValues: [ValueKey: Any] = [:]

        public subscript(record: Record, column: any IColumn) -> Any? {
            get { storedValues[ValueKey(record, column)] }
            set(value) { storedValues[ValueKey(record, column)] = value }
        }
    }
}
