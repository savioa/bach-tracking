import SwiftData

@Model
class Series: Nameable, Identifiable {
    @Attribute(.unique)
    var name: String
    @Relationship(deleteRule: .cascade, inverse: \Concert.series)
    var concerts: [Concert] = [Concert]()

    required init(name: String) {
        self.name = name
    }

    func getUsageCount() -> Int {
        return concerts.count
    }
}
