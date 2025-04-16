import Foundation
import SwiftData

@Model
class Artist: Identifiable {
    var id: UUID
    @Attribute(.unique)
    var name: String
    var type: ArtistType
    @Relationship(inverse: \Performance.artists)
    var performances: [Performance] = []

    @Transient
    var concerts: [Concert] {
        let set: Set<Concert> = Set(performances.compactMap { $0.concert })
        return set.sorted { $0.date > $1.date }
    }

    init(id: UUID = UUID(), name: String, type: ArtistType) {
        self.id = id
        self.name = name
        self.type = type
    }
}
