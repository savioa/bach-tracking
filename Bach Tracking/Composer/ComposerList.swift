import SwiftData
import SwiftUI

struct ComposerList: View {
    @State private var query = ""
    @State private var isAdding = false

    @Query private var composers: [Composer]

    private var filteredComposers: [Composer] {
        if query.isEmpty {
            composers
        } else {
            composers.filter { $0.fullName.localizedStandardContains(query) }
        }
    }

    var body: some View {
        var groupedComposers: [String: [Composer]] {
            Dictionary(grouping: filteredComposers) { String($0.shortName.prefix(1)) }
        }

        List {
            ForEach(Array(groupedComposers.keys).sorted(), id: \.self) { firstLetter in
                ProminentSection(header: Text(firstLetter)) {
                    let composersByLetter: [Composer]? = groupedComposers[firstLetter]?.sorted {
                        $0.shortName < $1.shortName
                    }

                    ForEach(composersByLetter ?? [], id: \.id) { composer in
                        NavigationLink {
                            ComposerDetail(composer: composer)
                        } label: {
                            let highlightedComposerName: Text = Text(composer) { string in
                                if let range: Range<AttributedString.Index> = string.range(
                                    of: composer.shortName)
                                {
                                    string[range].font = Font.system(.body).bold()
                                }
                            }

                            MultilineRow(firstLine: highlightedComposerName)
                        }
                    }
                }
            }
        }
        .navigationTitle("Compositores")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isAdding) {
            ComposerEditor(composer: Composer?(nil))
        }
        .toolbar { AddButtonToolbarItem(isAdding: $isAdding) }
        .searchable(
            text: $query, placement: .navigationBarDrawer(displayMode: .always),
            prompt: Text("Buscar"))
    }
}

extension Text {
    init(_ composer: Composer, configure: ((inout AttributedString) -> Void)) {
        var attributedString: AttributedString = AttributedString(composer.fullName)
        configure(&attributedString)
        self.init(attributedString)
    }
}

#Preview {
    NavigationStack {
        ComposerList()
    }
}
