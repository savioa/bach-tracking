import Foundation
import SwiftData

@Model
class Performance: Identifiable {
    var work: Work
    var artists: [Artist]
    var detail: String
    @Relationship(inverse: \Concert.performances)
    var concert: Concert?

    init(work: Work, artists: [Artist], detail: String) {
        self.work = work
        self.artists = artists
        self.detail = detail
    }
}
