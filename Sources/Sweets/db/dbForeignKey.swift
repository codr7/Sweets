extension db {    
    public class ForeignKey: Constraint {
        public enum Action: String {
            case cascade = "CASCADE"
            case restrict = "RESTRICT"
        }
        
        let foreignTable: Table
        let foreignColumns: [IColumn]
        let onUpdate: Action
        let onDelete: Action
        
        public init(_ name: String, _ table: Table, _ foreignColumns: [IColumn],
                    isNullable: Bool = false, isPrimaryKey: Bool = false,
                    onUpdate: Action = .cascade, onDelete: Action = .restrict) {
            self.onUpdate = onUpdate
            self.onDelete = onDelete
            foreignTable = foreignColumns[0].table
            self.foreignColumns = foreignColumns
            var columns: [IColumn] = []

            for fc in foreignColumns {
                if fc.table !== foreignTable {
                    fatalError("Table mismatch: \(table)/\(fc.table)")
                }

                columns.append(fc.clone("\(name)\(fc.name.capitalized)", table,
                                        isNullable: isNullable,
                                        isPrimaryKey: isPrimaryKey))
            }

            super.init(name, columns)
            table.definitions.append(self)
            table.foreignKeys.append(self)
        }

        public convenience init(_ name: String, _ table: Table, _ foreignTable: Table,
                                isNullable: Bool = false, isPrimaryKey: Bool = false,
                                onUpdate: Action = .cascade, onDelete: Action = .restrict) {
            self.init(name, table, foreignTable.primaryKey.columns,
                      isNullable: isNullable, isPrimaryKey: isPrimaryKey,
                      onUpdate: onUpdate, onDelete: onDelete)
        }
        
        public let constraintType = "FOREIGN KEY"

        public var createSql: String {
            "\(db.createSql(self)) REFERENCES \(foreignTable.nameSql) (\(foreignColumns.sql)) " +
              "ON UPDATE \(onUpdate.rawValue) ON DELETE \(onDelete.rawValue)"
        }

        public var dropSql: String { db.dropSql(self) }
    }
}

extension String {
    var capitalized: String {
        let c1 = self.prefix(1).uppercased()
        let cs = self.dropFirst().lowercased()
        return c1 + cs
    }
}
