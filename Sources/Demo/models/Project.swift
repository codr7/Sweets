import Sweets

extension demo {
    public class Project: Model {
        public var tables: [db.Table] { [cx.schema.projects] }
        
        public var name: String? {
            get { record[cx.schema.projectName] }
            set(v) { record[cx.schema.projectName] = v }
        }

        public var notes: String? {
            get { record[cx.schema.projectNotes] }
            set(v) { record[cx.schema.projectNotes] = v }
        }
    }
}
