import SwiftData
import SwiftUI

struct ConcertList: View {
    @State private var isAdding = false

    @Query(sort: \Concert.date, order: .reverse) private var concerts: [Concert]

    var body: some View {
        var formatter: DateFormatter {
            let formatter: DateFormatter = DateFormatter()
            formatter.locale = Locale(identifier: "pt_BR")
            formatter.dateFormat = "MMMM 'de' yyyy"
            return formatter
        }

        var groupedConcerts: [Int: [Concert]] {
            Dictionary(grouping: concerts) {
                $0.date.yearMonth
            }
        }

        List {
            ForEach(Array(groupedConcerts.keys.sorted().reversed()), id: \.self) { yearMonth in
                ProminentSection(formatter.string(for: groupedConcerts[yearMonth]![0].date)!) {
                    let concertsByMonth: [Concert]? = groupedConcerts[yearMonth]?.sorted {
                        $0.date > $1.date
                    }

                    ForEach(concertsByMonth ?? [], id: \.id) { concert in
                        NavigationLink {
                            ConcertDetail(concerts: concerts, selected: concert)
                        } label: {
                            MultilineConcertRow(concert: concert)
                        }
                    }
                }
            }
        }
        .navigationTitle("Concertos")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isAdding) {
            ConcertEditor(concert: Concert?(nil))
        }
        .toolbar { AddButtonToolbarItem(isAdding: $isAdding) }
    }
}
