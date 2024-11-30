extension dom {
    public typealias Tag = BasicTag & ITag
    
    public protocol ITag: INode {
        var attributes: [Attribute:Any] {get}
        var body: [INode] {get}
        var tag: String {get}

        subscript<T>(key: BasicAttribute<T>) -> T? {get set}

        @discardableResult
        func append<T>(_ node: T) -> T where T: INode
    }

    public class BasicTag {
        public var attributes: [Attribute:Any] = [:]
        public var body: [INode] = []

        public init() {}
        
        public subscript<T>(key: BasicAttribute<T>) -> T? {
            get { if let value = attributes[key] { (value as! T) } else { nil } }
            set(value) { attributes[key] = value }
        }
        
        @discardableResult
        public func append<T>(_ node: T) -> T where T: INode {
            body.append(node)
            return node
        }
    }
    
    public class CustomTag: Tag {
        public let tag: String
        
        public init(_ tag: String) {
            self.tag = tag
        }
    }
}

public extension dom.ITag {
    var html: String {
        var result = "<\(tag)"
        
        if !attributes.isEmpty {
            result += " \(attributes.map({$0.html($1)}).joined(separator: " "))"
        }
        
        result += body.isEmpty
          ? "/>"
          : ">\(body.map({$0.html}).joined(separator: ""))</\(tag)>"
        
        return result
    }

    @discardableResult
    func text(_ body: String) -> dom.ITag {
        append(dom.Text(body))
        return self
    }
}
