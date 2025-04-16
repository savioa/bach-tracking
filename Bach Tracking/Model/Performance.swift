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

struct PerformanceDTO: Codable {
    var work: WorkDTO
    var artists: [ArtistDTO]
    var detail: String

    init(from performance: Performance) {
        self.work = WorkDTO(from: performance.work)
        self.artists = performance.artists.map { ArtistDTO(from: $0) }
        self.detail = performance.detail
    }
}
