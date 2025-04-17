import Foundation
import SwiftData

@Model
class Concert: Identifiable {
    var id: UUID
    var date: Date
    var venue: Venue
    var series: Series?
    var seriesInstance: Int?
    var name: String
    var performances: [Performance]

    @Transient var title: String {
        var derivedTitle = ""

        if let series {
            derivedTitle = series.name
        }

        if let seriesInstance {
            derivedTitle += " \(String(seriesInstance))"
        }

        if name.isEmpty {
            return derivedTitle
        } else {
            return derivedTitle.isEmpty ? name : "\(name) (\(derivedTitle))"
        }
    }

    init(
        id: UUID = UUID(), date: Date, venue: Venue, series: Series?, seriesInstance: Int?,
        name: String, performances: [Performance]
    ) {
        self.id = id
        self.date = date
        self.venue = venue
        self.series = series
        self.seriesInstance = seriesInstance
        self.name = name
        self.performances = performances
    }
}

struct ConcertDTO: Codable {
    var name: String
    var date: Date
    var venue: String
    var series: String?
    var seriesInstance: Int?
    var performances: [PerformanceDTO]

    init(from concert: Concert) {
        self.name = concert.name
        self.date = concert.date
        self.venue = concert.venue.name
        self.series = concert.series?.name
        self.seriesInstance = concert.seriesInstance
        self.performances = concert.performances.map { PerformanceDTO(from: $0) }
    }
}
