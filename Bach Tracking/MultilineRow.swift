import SwiftUI

struct MultilineRow: View {
    let firstLine: Text
    let firstLineDetail: Text?
    let secondLine: Text?

    init(firstLine: Text, firstLineDetail: Text? = nil, secondLine: Text? = nil) {
        self.firstLine = firstLine
        self.firstLineDetail = firstLineDetail
        self.secondLine = secondLine
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 4) {
                firstLine
                if let firstLineDetail: Text {
                    firstLineDetail
                }
                if let secondLine: Text {
                    secondLine.font(.footnote).foregroundColor(.secondary)
                }
            }
        }
    }
}

struct MultilineConcertRow: View {
    let concert: Concert

    var body: some View {
        let firstLine: Text = Text(concert.title)
        let secondLine: Text = Text(concert.date.formatted())

        MultilineRow(firstLine: firstLine, secondLine: secondLine)
    }
}

struct MultilineArtistRow: View {
    let artist: Artist

    var body: some View {
        let firstLine: Text = Text(artist.name)
        let secondLine: Text = Text(artist.type.name)

        MultilineRow(firstLine: firstLine, secondLine: secondLine)
    }
}

struct MultilinePerformanceRow: View {
    let performance: Performance

    var body: some View {
        let firstLine: Text = Text(
            (performance.encore ? "* " : "")
                + performance.work.primaryTitle
                + (performance.detail.isEmpty ? "" : " (\(performance.detail))"))
        let secondLine: Text = Text(performance.work.composer.shortName)

        MultilineRow(firstLine: firstLine, secondLine: secondLine)
    }
}

struct MultilineWorkRow: View {
    let work: Work

    var body: some View {
        let firstLine: Text = Text(work.primaryTitle)
        let secondLine: Text? = work.hasDerivedTitle() ? Text(work.derivedTitle) : nil

        MultilineRow(firstLine: firstLine, secondLine: secondLine)
    }
}
