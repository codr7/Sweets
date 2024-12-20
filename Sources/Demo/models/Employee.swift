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

        @discardableResult
        public func add(role: Role) async throws -> Employee {
            var er = EmployeeRole(self, role)
            try await er.store()
            return self
        }

        public func has(role: Role) async throws -> Bool {
            try await cx.schema.employeeRoles.recordExists(
              cx.schema.employeeRoleEmployee == self.record &&
                cx.schema.employeeRoleRole == role.record,
              cx.db)
        }
    }

    public class EmployeeRole: Model {
            public var tables: [db.Table] { [cx.schema.employeeRoles] }
            
            public init(_ employee: Employee, _ role: Role) {
                super.init(employee.cx)
                record[cx.schema.employeeRoleEmployee] = employee.record
                record[cx.schema.employeeRoleRole] = role.record
            }
    }
}
