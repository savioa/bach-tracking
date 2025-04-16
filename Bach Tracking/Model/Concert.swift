import Foundation
import SwiftData

@Model
class Concert: Identifiable {
    var date: Date
    var venue: Venue
    var series: Series?
    var seriesInstance: Int?
    var name: String
    var performances: [Performance]

    @Transient var title: String {
        var derivedTitle: String = ""

        if let series: Series {
            derivedTitle = series.name
        }

        if let seriesInstance: Int {
            derivedTitle += " \(String(seriesInstance))"
        }

        if name.isEmpty {
            return derivedTitle
        } else {
            return derivedTitle.isEmpty ? name : "\(name) (\(derivedTitle))"
        }
    }

    init(
        date: Date, venue: Venue, series: Series?, seriesInstance: Int?, name: String,
        performances: [Performance]
    ) {
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
