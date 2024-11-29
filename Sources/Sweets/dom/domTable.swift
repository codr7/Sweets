extension dom {
    public class Table: BasicNode {
        public class Row: BasicNode {
            public init() { super.init("tr") }

            public func td() -> Data { append(Data()) }
        }

        public class Data: BasicNode {
            nonisolated(unsafe) public static let Colspan =
              BasicAttribute<Int>("colspan")
            
            public init() { super.init("td") }
        }
        
        public init() {
            super.init("table")
        }

        public func tr() -> Row { append(Row()) }
    }
}
