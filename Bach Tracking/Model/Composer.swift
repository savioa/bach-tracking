import SwiftData
import UniformTypeIdentifiers

@Model
class Composer: Identifiable {
    var id: UUID
    var fullName: String
    @Attribute(.unique)
    var shortName: String
    @Relationship(deleteRule: .cascade, inverse: \Work.composer)
    var works: [Work] = [Work]()

    init(id: UUID = UUID(), fullName: String, shortName: String) {
        self.id = id
        self.fullName = fullName
        self.shortName = shortName
    }
}

struct ComposerDTO: Codable {
    var fullName: String
    var shortName: String

    init(from composer: Composer) {
        self.fullName = composer.fullName
        self.shortName = composer.shortName
    }
}
