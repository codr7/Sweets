extension dom {
    public protocol INode {
        var html: String {get}
    }

    public class Text: INode {
        public let html: String
        
        public init(_ html: String) {
            self.html = html
        }
    }
}
