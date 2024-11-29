extension dom {
    public class Document {
        public class Head: BasicNode {
            nonisolated(unsafe) public static let Title =
              BasicAttribute<String>("title")
        }
        
        public let body: BasicNode
        public let head: Head
        public let root = BasicNode("html")

        public init() {
            head = root.append(Head("head"))
            body = root.append(BasicNode("body"))
        }
    }
}
