import Sweets

extension demo {
    public class Employee: Model {
        public var tables: [db.Table] { [cx.schema.employees] }
        
        public var email: String? {
            get { record[cx.schema.employeeEmail] }
            set(v) { record[cx.schema.employeeEmail] = v }
        }

        public var name1: String? {
            get { record[cx.schema.employeeName1] }
            set(v) { record[cx.schema.employeeName1] = v }
        }

        public var name2: String? {
            get { record[cx.schema.employeeName2] }
            set(v) { record[cx.schema.employeeName2] = v }
        }
    }
}
