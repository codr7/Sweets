import Sweets

extension demo {
    public class Schema: db.Schema {
        public let employees = db.Table("employees")
        public let employeeEmail: db.StringColumn
        public let employeeName1: db.StringColumn 
        public let employeeName2: db.StringColumn
        public let employeeNotes: db.StringColumn

        public let employeeRoles = db.Table("employeeRoles")
        public let employeeRoleEmployee: db.ForeignKey
        public let employeeRoleRole: db.ForeignKey
        
        public let projects = db.Table("projects")
        public let projectName: db.StringColumn
        public let projectNotes: db.StringColumn

        public let projectMembers = db.Table("projectMembers")
        public let projectMemberProject: db.ForeignKey
        public let projectMemberMember: db.ForeignKey
        public let projectMemberRole: db.ForeignKey

        public let roles = db.Table("roles")
        public let roleName: db.StringColumn
        public let roleNotes: db.StringColumn

        public override init() {
            employeeEmail = db.StringColumn("email", employees, isPrimaryKey: true)
            employeeName1 = db.StringColumn("name1", employees)
            employeeName2 = db.StringColumn("name2", employees)
            employeeNotes = db.StringColumn("notes", employees)

            roleName = db.StringColumn("name", roles, isPrimaryKey: true)
            roleNotes = db.StringColumn("notes", roles)

            employeeRoleEmployee = db.ForeignKey("employee", employeeRoles, employees,
                                                 isPrimaryKey: true)
            employeeRoleRole = db.ForeignKey("role", employeeRoles, roles,
                                             isPrimaryKey: true)

            projectName = db.StringColumn("name", projects, isPrimaryKey: true)
            projectNotes = db.StringColumn("notes", projects)

            projectMemberProject = db.ForeignKey("project", projectMembers, projects,
                                                 isPrimaryKey: true)
            projectMemberMember = db.ForeignKey("member", projectMembers, employees,
                                                isPrimaryKey: true)  
            projectMemberRole = db.ForeignKey("role", projectMembers, roles)

            
            super.init()
            register(employees, roles, employeeRoles, projects, projectMembers)
        }
    }
}
