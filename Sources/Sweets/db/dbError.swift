extension db {
    public enum DatabaseError: Error {
        case noRows
        case missingKey(String)
    }
}
