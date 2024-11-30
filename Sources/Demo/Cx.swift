import Sweets

extension demo {
    public class Cx {
        public let db: db.Cx
        public let schema = Schema()

        public init(_ db: db.Cx) {
            self.db = db
        }
    }
}
