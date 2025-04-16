import SwiftData

@Model
class ArtistType: Nameable, Identifiable {
    @Attribute(.unique)
    var name: String
    @Relationship(deleteRule: .cascade, inverse: \Artist.type)
    var artists: [Artist] = [Artist]()

    required init(name: String) {
        self.name = name
    }

    func getUsageCount() -> Int {
        return artists.count
    }
}
