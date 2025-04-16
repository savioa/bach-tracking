import SwiftData

@Model
class MusicalForm: Nameable, Identifiable {
    @Attribute(.unique)
    var name: String
    @Relationship(deleteRule: .cascade, inverse: \Work.form)
    var works: [Work] = [Work]()

    required init(name: String) {
        self.name = name
    }

    func getUsageCount() -> Int {
        return works.count
    }
}
