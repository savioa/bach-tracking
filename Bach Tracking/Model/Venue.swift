import SwiftData

@Model
class Venue: Nameable, Identifiable {
    @Attribute(.unique)
    var name: String
    @Relationship(deleteRule: .cascade, inverse: \Concert.venue)
    var concerts: [Concert] = [Concert]()

    required init(name: String) {
        self.name = name
    }

    func getUsageCount() -> Int {
        return concerts.count
    }
}
