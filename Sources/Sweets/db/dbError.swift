extension db {
    class BasicError: CustomStringConvertible, Error, @unchecked Sendable {
        let description: String
        
        init(_ description: String) {
            self.description = description
        }
    }
}
