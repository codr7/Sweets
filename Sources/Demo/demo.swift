import Sweets

public struct demo {}

@main
public extension demo {
    static func run() async throws {
        print("Welcome")
        
        let db = db.Cx(database: "sweets", user: "sweets", password: "sweets")
        try await db.connect()
        
        let cx = Cx(db)
        let tx = try await cx.db.startTx()
        try await cx.schema.drop(cx.db)
        try await cx.schema.create(cx.db)

        var e = Employee(cx)
        e.name1 = "Andreas"
        e.name2 = "Nilsson"
        e.email = "codr7@protonmail.com"
        try await e.store()

        let le = try await cx.schema.employees.find(record: e.record, cx.db)!
        assert(le == e.record)

        var r = Role(cx)
        r.name = "Tech Lead"
        try await r.store()

        try await e.add(role: r)

        var p = Project(cx)
        p.name = "Opus Magnum"
        try await p.store()

        try await p.add(member: e, role: r)

        var m = Milestone(p)
        m.name = "Default"
        try await m.store()
        
        var t = Task(m)
        try await t.store()
        try await tx.commit()
        
        try await http.start()
        try await cx.db.disconnect()
    }

    static func main() async throws {
        try await run()
    }
}

