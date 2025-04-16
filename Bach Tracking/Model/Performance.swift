import Foundation
import SwiftData

@Model
class Performance: Identifiable {
    var work: Work
    var artists: [Artist]
    var detail: String
    var encore: Bool
    @Relationship(inverse: \Concert.performances)
    var concert: Concert?

    init(work: Work, artists: [Artist], detail: String, encore: Bool) {
        self.work = work
        self.artists = artists
        self.detail = detail
        self.encore = encore
    }
}

struct PerformanceDTO: Codable {
    var work: WorkDTO
    var artists: [ArtistDTO]
    var detail: String
    var encore: Bool

    init(from performance: Performance) {
        self.work = WorkDTO(from: performance.work)
        self.artists = performance.artists.map { ArtistDTO(from: $0) }
        self.detail = performance.detail
        self.encore = performance.encore
    }
}
