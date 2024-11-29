import Foundation
import PostgresNIO
import Sweets;

extension db {
    static func getCx() async throws -> Cx {
        let cx = Cx(database: "sweets", user: "sweets", password: "sweets")
        try await cx.connect()
        return cx
    }
    
    static func conditionTests() {
        let scm = Schema()
        let tbl = Table(scm, "tbl")
        let col = StringColumn("col", tbl)
        
        let c = (col == "foo") || (col == 42)
        assert(c.conditionSql == "(\(col.valueSql) = ?) OR (\(col.valueSql) = ?)")
    }
    
    static func foreignKeyTests() async throws {
        let scm = Schema()
        let tbl1 = Table(scm, "tbl1")
        let col1 = IntColumn("col", tbl1, isPrimaryKey: true)
        
        let tbl2 = Table(scm, "tbl2")
        _ = ForeignKey("fkey", tbl2, [col1], isPrimaryKey: true)
        
        let cx = try await getCx()
        var tx = try await cx.startTx()
        try await scm.create(cx)
        try await tx.rollback()
        
        tx = try await cx.startTx()
        try await scm.sync(cx)
        try await tx.rollback()
        
        try await cx.disconnect()
    }

    class TestModel: Model {
        let tables: [Table]
        
        init(_ cx: Cx, _ tables: [Table], _ record: Record? = nil) {
            self.tables = tables
            super.init(cx, record)
        }
    }

    static func modelTests() async throws {
        let scm = Schema()
        let tbl1 = Table(scm, "tbl1")
        let col1 = IntColumn("col", tbl1, isPrimaryKey: true)

        let cx = try await getCx()
        let tx = try await cx.startTx()
        try await scm.sync(cx)
        let m = TestModel(cx, [tbl1])
        assert(!m.isModified)
        m.record[col1] = 42
        assert(m.isModified)
        try await m.store()
        assert(!m.isModified)

        try await tx.rollback()
        try await cx.disconnect()
    }
    
    static func orderedSetTests() {
        func compareInts(l: Int, r: Int) -> Order {
            return
              if l < r { .less }
              else if l > r { .greater }
              else { .equal }
        }
        
        var s = OrderedSet<Int, Int>(compare)
        
        assert(s.index(of: 42) == (0, nil))
        
        assert(s.add(1))
        assert(!s.add(1))
        assert(s.add(3))
        assert(s.add(2))
        assert(s.count == 3)
        
        assert(s.remove(2) == 2)
        assert(s.count == 2)
        
        assert(s[1] == 1)
        assert(s[2] == nil)
        assert(s[3] == 3)
    }
    
    static func queryTests() async throws {
        let scm = Schema()
        let tbl = Table(scm, "tbl")
        let col1 = StringColumn("col1", tbl, isPrimaryKey: true)
        let col2 = StringColumn("col2", tbl)
        
        let q = Query()
        q.select(col1, col2)
        q.from(tbl)
        q.filter(col1 == "foo")
        let cx = try await getCx()
        let tx = try await cx.startTx()
        try await scm.sync(cx)
        try await q.exec(cx)
        try await tx.rollback()
        try await cx.disconnect()
    }
    
    enum TestEnum: String, Enum {
        case foo = "foo"
        case bar = "bar"
        case baz = "baz"
    }
    
    static func recordTests() async throws {
        let scm = Schema()
        let tbl = Table(scm, "tbl")
        let boolCol = BoolColumn("bool", tbl)
        let dateCol = DateColumn("date", tbl)
        let decimalCol = DecimalColumn("decimal", tbl)
        let enumCol = EnumColumn<TestEnum>("enum", tbl)
        let intCol = IntColumn("int", tbl, isPrimaryKey: true)
        let stringCol = StringColumn("string", tbl)
        let rec = Record()
        
        rec[boolCol] = true
        assert(rec[boolCol]! == true)
        
        let now = Date.now
        rec[dateCol] = now
        assert(rec[dateCol]! == now)
        
        let d = Decimal(4.2)
        rec[decimalCol] = d 
        assert(rec[decimalCol] == d)
        
        rec[enumCol] = .foo
        assert(rec[enumCol]! == .foo)
        
        rec[intCol] = 1
        assert(rec[intCol]! == 1)
        
        rec[stringCol] = "foo"
        assert(rec[stringCol]! == "foo")
        
        assert(rec.count == 6)
        
        let cx = try await getCx()
        var tx = try await cx.startTx()
        try await scm.sync(cx)
        try await tx.commit()
        tx = try await cx.startTx()

        assert(!rec.isStored(tbl.columns, cx))
        assert(rec.isModified(tbl.columns, cx))
        try await tbl.store(rec, cx)
        assert(rec.isStored(tbl.columns, cx))
        assert(!rec.isModified(tbl.columns, cx))

        rec[intCol] = 2
        assert(rec[intCol]! == 2)
        assert(rec.isModified(tbl.columns, cx))
        try await tbl.store(rec, cx)
        assert(rec.isStored(tbl.columns, cx))
        assert(!rec.isModified(tbl.columns, cx))

        try await scm.drop(cx)
        try await tx.commit()
        try await cx.disconnect()
    }

    static func runTests() async throws {
        conditionTests()
        try await foreignKeyTests()
        orderedSetTests()
        try await queryTests()
        try await recordTests()
    }
}
