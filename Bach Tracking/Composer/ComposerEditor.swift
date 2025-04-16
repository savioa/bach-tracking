import CoreSpotlight
import SwiftData
import SwiftUI

struct ComposerEditor: View {
    @Environment(\.dismiss) var dismiss: DismissAction
    @Environment(\.modelContext) private var modelContext: ModelContext

    @State private var fullName: String = ""
    @State private var shortName: String = ""
    @State private var newComposer: Bool = true

    let composer: Composer?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Nome completo", text: $fullName).textInputAutocapitalization(.words)

                    PrefixedTextField(
                        prefix: "ou apenas", placeholder: "Nome resumido", text: $shortName,
                        capitalization: .words)
                }
            }
            .navigationTitle(newComposer ? "Novo Compositor" : "")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar", role: .cancel) { dismiss() }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") { save() }.disabled(!fullName.contains(shortName))
                }
            }
        }
        .onAppear {
            if let composer: Composer {
                fullName = composer.fullName
                shortName = composer.shortName
                newComposer = false
            }
        }
    }

    func save() {
        let indexingComposer: Composer

        if let composer: Composer {
            composer.fullName = fullName.trimmed
            composer.shortName = shortName.trimmed
            indexingComposer = composer
        } else {
            let composer: Composer = Composer(
                fullName: fullName.trimmed, shortName: shortName.trimmed)

            modelContext.insert(composer)
            indexingComposer = composer
        }

        try? modelContext.save()

        indexComposerInSpotlight(indexingComposer)

        dismiss()
    }

    func indexComposerInSpotlight(_ composer: Composer) {
        let attributeSet: CSSearchableItemAttributeSet = CSSearchableItemAttributeSet(
            itemContentType: UTType.text.identifier)

        attributeSet.title = composer.fullName
        attributeSet.contentDescription = "Compositor"
        attributeSet.keywords = [composer.shortName, composer.fullName]
        attributeSet.thumbnailData = safeThumbnailData(for: composer.shortName)

        let item: CSSearchableItem = CSSearchableItem(
            uniqueIdentifier: "composer.\(composer.id.uuidString)",
            domainIdentifier: "com.seudominio.bachtracking.composer",
            attributeSet: attributeSet
        )

        CSSearchableIndex.default().indexSearchableItems([item])
    }
}
