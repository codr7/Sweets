extension dom {
    public class Document {
        public class Head: Node {
            nonisolated(unsafe) public static let Title =
              BasicAttribute<String>("title")

            public let tag = "head"
        }
        
        public let body: INode
        public let head: Head
        public let root = CustomNode("html")

        public init() {
            head = root.append(Head())
            body = root.append(CustomNode("body"))
        }
    }
}
