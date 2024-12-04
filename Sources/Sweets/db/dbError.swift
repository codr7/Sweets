extension db {
    public class BasicError: CustomStringConvertible, Error, @unchecked Sendable {
        public let description: String
        
        public init(_ description: String) {
            self.description = description
        }
    }
}
