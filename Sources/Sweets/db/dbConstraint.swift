extension db {
    public typealias Constraint = BasicConstraint & IConstraint
    
    public protocol IConstraint: ITableDefinition {
        var columns: [IColumn] {get}
        var constraintType: String {get}
    }

    public class BasicConstraint: BasicTableDefinition {
        public let columns: [IColumn]

        public init(_ name: String, _ columns: [IColumn]) {
            let table = columns[0].table

            for c in columns[1...] {
                if c.table !== table {
                    fatalError("Table mismatch: \(table)/\(c.table)")
                }
            }
            
            self.columns = columns
            super.init(name, table)
        }
        
        public var definitionType: String {
            "CONSTRAINT"
        }

        public func exists(_ cx: Cx) async throws -> Bool {
            try await cx.queryValue(
              """
                SELECT EXISTS (
                  SELECT constraint_name 
                  FROM information_schema.constraint_column_usage 
                  WHERE table_name = \(table.nameSql)
                  AND constraint_name = \(nameSql)
                )
                """
            )
        }
    }

    public static func createSql(_ c: IConstraint) -> String {
        "\(createSql(c as ITableDefinition)) \(c.constraintType) (\(c.columns.sql))"
    }
}
