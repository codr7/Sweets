public extension db {
    protocol Source {
        var sourceSql: String {get}
        var sourceParams: [any Encodable] {get}
    }
}

public extension db.Source {
    var sourceParams: [any db.Encodable] {
        []
    }
}

public extension [any db.Source] {
    var sql: String {
        self.map({$0.sourceSql}).joined(separator: ", ")
    }
}
