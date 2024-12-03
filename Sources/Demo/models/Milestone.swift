import Sweets

extension demo {
    public class Milestone: Model {
        public init(_ project: Project) {
            super.init(project.cx)
            record[cx.schema.milestoneProject] = project.record
        }

        public override init(_ cx: Cx, _ record: db.Record) {
            super.init(cx, record)
        }
        
        public var tables: [db.Table] { [cx.schema.milestones] }
        
        public var project: Project {
            get { Project(cx, record[cx.schema.milestoneProject]) }
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
