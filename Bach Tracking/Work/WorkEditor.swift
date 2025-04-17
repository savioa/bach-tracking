import CoreSpotlight
import SwiftData
import SwiftUI

struct WorkEditor: View {
    @Environment(\.dismiss) private var dismiss: DismissAction
    @Environment(\.modelContext) private var modelContext: ModelContext

    @State private var name = ""
    @State private var form: MusicalForm?
    @State private var instruments = ""
    @State private var number = ""
    @State private var tonality: Work.Tonality?
    @State private var opus = ""
    @State private var catalogue = ""
    @State private var nickname = ""
    @State private var detail = ""
    @State private var navigationTitle = "Nova Obra"

    @Query var forms: [MusicalForm]

    let work: Work?
    let composer: Composer

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Nome", text: $name)

                    CustomMenuPicker(
                        title: "Forma", items: forms, selection: $form, label: { $0.name },
                        nilTitle: "Forma não definida")

                    PrefixedTextField(
                        prefix: "para", placeholder: "Instrumentos", text: $instruments,
                        capitalization: .never)

                    PrefixedTextField(prefix: "n.º", placeholder: "Número", text: $number)

                    CustomMenuPicker(
                        title: "Tonalidade", items: Work.Tonality.allCases, selection: $tonality,
                        label: { $0.rawValue },
                        nilTitle: "Tonalidade não definida")

                    PrefixedTextField(prefix: "Op.", placeholder: "Opus", text: $opus)

                    TextField("Identificação em catálogo", text: $catalogue)

                    TextField("Apelido", text: $nickname)

                    TextField("Detalhe", text: $detail)
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                FormToolbar.items(
                    isConfirmDisabled: name.isEmpty && form == nil, onConfirm: { save() })
            }
        }
        .onAppear {
            if let work: Work {
                name = work.name
                form = work.form
                instruments = work.instruments
                number = work.number
                tonality = work.tonality
                opus = work.opus
                catalogue = work.catalogue
                nickname = work.nickname
                detail = work.detail
                navigationTitle = ""
            }
        }
    }

    func save() {
        let indexingWork: Work

        if let work: Work {
            work.name = name.trimmed
            work.form = form
            work.instruments = instruments.trimmed
            work.number = number.trimmed
            work.tonality = tonality
            work.opus = opus.trimmed
            work.catalogue = catalogue.trimmed
            work.nickname = nickname.trimmed
            work.detail = detail.trimmed
            indexingWork = work
        } else {
            let work: Work = Work(
                name: name.trimmed, detail: detail.trimmed, opus: opus.trimmed,
                catalogue: catalogue.trimmed, form: form,
                tonality: tonality, nickname: nickname.trimmed, number: number.trimmed,
                composer: composer,
                instruments: instruments.trimmed)

            modelContext.insert(work)
            indexingWork = work
        }

        try? modelContext.save()

        indexWorkInSpotlight(indexingWork)

        dismiss()
    }

    func indexWorkInSpotlight(_ work: Work) {
        let attributeSet: CSSearchableItemAttributeSet = CSSearchableItemAttributeSet(
            itemContentType: UTType.text.identifier)

        attributeSet.title = work.primaryTitle
        attributeSet.contentDescription = work.composer.shortName
        attributeSet.keywords = [
            work.composer.fullName, work.composer.shortName, work.primaryTitle, work.derivedTitle,
        ]

        if work.hasDerivedTitle() {
            attributeSet.title = "\(work.primaryTitle)\n\(work.derivedTitle)"
            attributeSet.keywords?.append(work.derivedTitle)
        }

        let item: CSSearchableItem = CSSearchableItem(
            uniqueIdentifier: "work.\(work.id.uuidString)",
            domainIdentifier: "com.seudominio.bachtracking.work",
            attributeSet: attributeSet
        )

        CSSearchableIndex.default().indexSearchableItems([item])
    }
}
