import Sweets

extension dom {
    static func runTests() {
        let doc = Document()
        doc.head[Document.Head.Title] = "Title"
        let t = doc.body.append(Table())
        let tr = t.tr()
        let td = tr.td()
        td[Table.Data.Colspan] = 2
        td.text("Body")
        assert(doc.root.html == "<html><head title=\"Title\"/><body><table><tr><td colspan=\"2\">Body</td></tr></table></body></html>")
    }
}
