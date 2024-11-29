extension dom {
    public class Attribute: Equatable, Hashable {
        public static func ==(_ l: Attribute, _ r: Attribute) -> Bool {
            l.name == r.name
        }
        
        public init(_ name: String) {
            self.name = name
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(name)
        }

        public func html(_ value: Any) -> String { "\(name)=\"\(valueHtml(value))\"" }

        public var name: String

        public func valueHtml(_ value: Any) -> String { "\(value)" }
    }

    public class BasicAttribute<T>: Attribute {
        public override func valueHtml(_ value: Any) -> String {
            valueHtml(value as! T)
        }
        
        public func valueHtml(_ value: T) -> String { "\(value)" }
    }
}
