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

        @discardableResult
        public func add(member: Employee, role: Role) async throws -> Project {
            if !(try await member.has(role: role)) {
                 try await member.add(role: role)
            }
            
            var pm = ProjectMember(self, member, role)
            try await pm.store()
            return self
        }
    }

    public class ProjectMember: Model {
        public var tables: [db.Table] { [cx.schema.projectMembers] }
        
        public init(_ project: Project, _ member: Employee, _ role: Role) {
            super.init(project.cx)
            record[cx.schema.projectMemberProject] = project.record
            record[cx.schema.projectMemberMember] = member.record
            record[cx.schema.projectMemberRole] = role.record
        }
    }
}
