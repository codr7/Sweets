import Sweets

extension demo {
    public typealias Model = BasicModel & IModel
    
    public protocol IModel: db.IModel {
        var cx: Cx {get}
    }
    
    public class BasicModel: db.BasicModel {
        public let cx: Cx

        public init(_ cx: Cx, _ record: db.Record) {
            self.cx = cx
            super.init(cx.db, record)
        }
        
        public init(_ cx: Cx) {
            self.cx = cx
            super.init(cx.db)
        }
    }
}
