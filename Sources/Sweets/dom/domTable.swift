extension dom {
    public class Table: Node {
        public class Row: Node {
            public let tag = "tr"
            public func td() -> Data { append(Data()) }
        }

        public class Data: Node {
            nonisolated(unsafe) public static let Colspan =
              BasicAttribute<Int>("colspan")
            
            public let tag = "td"
        }
        
        public let tag = "table"
        public func tr() -> Row { append(Row()) }
    }
}
