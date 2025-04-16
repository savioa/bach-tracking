import SwiftData
import SwiftUI

struct NameableItemEditor<T: Nameable & PersistentModel>: View {
    @Environment(\.dismiss) var dismiss: DismissAction
    @Environment(\.modelContext) private var modelContext: ModelContext

    @State private var name: String = ""
    @State private var newItem: Bool = true

    let item: T?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Nome", text: $name)
                }
            }
            .navigationTitle(newItem ? T.newItemLabel : "")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar", role: .cancel) { dismiss() }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") { save() }.disabled(name.isEmpty)
                }
            }
        }
        .onAppear {
            if let item: T {
                name = item.name
                newItem = false
            }
        }
    }

    func save() {
        if var item: T {
            item.name = name.trimmed
        } else {
            let item: T = T(name: name.trimmed)

            modelContext.insert(item)
        }

        try? modelContext.save()

        dismiss()
    }
}