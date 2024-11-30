extension db {
    public protocol ITableDefinition: IDefinition {
        var table: Table {get}
    }

    public typealias TableDefinition = BasicTableDefinition & ITableDefinition
    
    public class BasicTableDefinition: BasicDefinition {
        public let table: Table

        public init(_ name: String, _ table: Table) {
            self.table = table
            super.init(name)
        }
    }

    public static func createSql(_ d: ITableDefinition) -> String {
        "ALTER TABLE \(d.table.nameSql) ADD \(d.definitionType) \(d.nameSql)"
    }

    public static func dropSql(_ d: ITableDefinition) -> String {
        "ALTER TABLE \(d.table.nameSql) DROP \(d.definitionType) \(d.nameSql)"
    }
}
