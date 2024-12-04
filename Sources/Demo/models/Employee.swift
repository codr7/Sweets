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
            let c = db.Query()
              .FROM(cx.schema.employeeRoles)
              .WHERE(
                try cx.schema.employeeRoleEmployee == self.record,
                try cx.schema.employeeRoleRole == role.record)
              .LIMIT(1)
              .EXISTS

            let r = try await db.Query().SELECT(c).exec(cx.db)
            if !(try await r.fetch()) { throw db.BasicError("Fetch failed") }
            return r[c]!.bool!
            
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
