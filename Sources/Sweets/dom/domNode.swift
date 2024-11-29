extension dom {
    public protocol Node {
        var attributes: [Attribute:Any] {get}
        var body: [Node] {get}
        var html: String {get}
        var tag: String {get}

        subscript<T>(key: BasicAttribute<T>) -> T? {get set}
    }

    public class BasicNode: Node {
        public let tag: String
        public var attributes: [Attribute:Any] = [:]
        public var body: [Node] = []

        public init(_ tag: String) {
            self.tag = tag
        }

        public subscript<T>(key: BasicAttribute<T>) -> T? {
            get { if let value = attributes[key] { (value as! T) } else { nil } }
            set(value) { attributes[key] = value }
        }
        
        @discardableResult
        public func append<T>(_ node: T) -> T where T: Node {
            body.append(node)
            return node
        }

        public var html: String {
            var result = "<\(tag)"

            if !attributes.isEmpty {
                result += " \(attributes.map({$0.html($1)}).joined(separator: " "))"
            }
            
            result += body.isEmpty
              ? "/>"
              : ">\(body.map({$0.html}).joined(separator: ""))</\(tag)>"

            return result
        }
    }
}
