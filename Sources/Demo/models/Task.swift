import Sweets

extension demo {
    public class Task: Model {
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
