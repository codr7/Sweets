extension dom {
    public class Document {
        public class Head: Tag {
            nonisolated(unsafe) public static let Title =
              BasicAttribute<String>("title")

            public let tag = "head"
        }
        
        public let body: ITag
        public let head: Head
        public let root = CustomTag("html")

        public init() {
            head = root.append(Head())
            body = root.append(CustomTag("body"))
        }
    }
}
