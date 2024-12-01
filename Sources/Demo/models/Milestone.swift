import Sweets

extension demo {
    public class Milestone: Model {
        public var tables: [db.Table] { [cx.schema.tasks] }
        
        public var project: Project {
            get { Project(cx, record[cx.schema.milestoneProject]) }
            set(v) { record[cx.schema.milestoneProject] = v.record }
        }

        public var name: String? {
            get { record[cx.schema.milestoneName] }
            set(v) { record[cx.schema.milestoneName] = v }
        }

        public var notes: String? {
            get { record[cx.schema.milestoneNotes] }
            set(v) { record[cx.schema.milestoneNotes] = v }
        }
    }
}
