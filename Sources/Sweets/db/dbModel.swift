extension db {
    public class Model {
        public let cx: Cx
        public let record: Record
        
        public init(_ cx: Cx, _ record: Record? = nil) {
            self.cx = cx
            self.record = record ?? Record()
        }
    }
}
