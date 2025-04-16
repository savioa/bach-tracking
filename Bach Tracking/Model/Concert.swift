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

        if series != nil {
            derivedTitle = series!.name
        }

        if seriesInstance != nil {
            derivedTitle += " \(String(seriesInstance!))"
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
