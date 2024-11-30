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
        try await cx.schema.sync(cx.db)

        //TODO: run
       
        try await tx.rollback()
        try await cx.db.disconnect()
    }

    static func main() async throws {
        try await run()
    }
}

