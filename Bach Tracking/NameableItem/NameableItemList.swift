import SwiftData
import SwiftUI

struct NameableItemList<T: Nameable & PersistentModel>: View {
    @State private var isAdding = false

    @Query(sort: \T.name) private var list: [T]

    var body: some View {
        List {
            ForEach(list) { item in
                NavigationLink {
                    NameableItemDetail(item: item)
                } label: {
                    HStack {
                        Text(item.name)
                        Spacer()
                        Text(String(item.getUsageCount()))
                    }
                }
            }
        }
        .navigationTitle(T.pluralFormItemName)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isAdding) {
            NameableItemEditor(item: T?(nil))
        }
        .toolbar { AddButtonToolbarItem(isAdding: $isAdding) }
    }
}

#Preview {
    NameableItemList<Venue>()
}
