import Sweets

extension demo {
    public class Task: Model {
        public init(_ milestone: Milestone) {
            super.init(milestone.cx)
            record[cx.schema.taskMilestone] = milestone.record
        }

        public override init(_ cx: Cx, _ record: db.Record) {
            super.init(cx, record)
        }
        
        public var tables: [db.Table] { [cx.schema.tasks] }
        
        public var id: db.Sequence.Value? {
            get { record[cx.schema.taskId] }
            set(v) { record[cx.schema.taskId] = v }
        }

        public var milestone: Milestone {
            get { Milestone(cx, record[cx.schema.taskMilestone]) }
            set(v) { record[cx.schema.taskMilestone] = v.record }
        }

        public var notes: String? {
            get { record[cx.schema.taskNotes] }
            set(v) { record[cx.schema.taskNotes] = v }
        }
    }
}
