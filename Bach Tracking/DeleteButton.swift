import SwiftData
import SwiftUI

struct DeleteButton<Item: PersistentModel>: View {
    @Environment(\.modelContext) private var modelContext: ModelContext
    @Environment(\.dismiss) private var dismiss: DismissAction

    var item: Item
    var afterDelete: (() -> Void)?

    var body: some View {
        Button("Apagar", role: .destructive) {
            modelContext.delete(item)

            try? modelContext.save()

            afterDelete?()
            dismiss()
        }
        .buttonStyle(.bordered)
        .tint(.red)
        .frame(maxWidth: .infinity, alignment: .center)
        .padding()
    }
}
