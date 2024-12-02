import Sweets

extension demo {
    public class Role: Model {
        public var tables: [db.Table] { [cx.schema.roles] }
        
        public var name: String? {
            get { record[cx.schema.roleName] }
            set(v) { record[cx.schema.roleName] = v }
        }

        public var notes: String? {
            get { record[cx.schema.roleNotes] }
            set(v) { record[cx.schema.roleNotes] = v }
        }
    }
}
