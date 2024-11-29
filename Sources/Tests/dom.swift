import Sweets

extension dom {
    static func runTests() {
        let doc = Document()
        doc.head[Document.Head.Title] = "Hello World!"
        let t = doc.body.append(Table())
        let tr = t.tr()
        let td = tr.td()
        td[Table.Data.Colspan] = 2
        
        assert(doc.root.html == "<html><head title=\"Hello World!\"/><body><table><tr><td colspan=\"2\"/></tr></table></body></html>")
    }
}
