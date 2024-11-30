import Sweets

extension demo {
    public class Schema: db.Schema {
        public let employees = db.Table("employees")
        public let employeeEmail: db.StringColumn
        public let employeeName1: db.StringColumn 
        public let employeeName2: db.StringColumn

        public let employeeRoles = db.Table("employeeRoles")
        public let employeeRolesSource: db.ForeignKey
        public let employeeRolesTarget: db.ForeignKey
        
        public let roles = db.Table("roles")
        public let roleName: db.StringColumn
        public let roleNotes: db.StringColumn

        public override init() {
            employeeEmail = db.StringColumn("email", employees, isPrimaryKey: true)
            employeeName1 = db.StringColumn("name1", employees)
            employeeName2 = db.StringColumn("name2", employees)

            roleName = db.StringColumn("name", roles, isPrimaryKey: true)
            roleNotes = db.StringColumn("notes", roles)

            employeeRolesSource = db.ForeignKey("source", employeeRoles, employees,
                                                isPrimaryKey: true)
            employeeRolesTarget = db.ForeignKey("target", employeeRoles, roles,
                                                isPrimaryKey: true)


            super.init()
            register(employees, roles, employeeRoles)
        }
    }
}
