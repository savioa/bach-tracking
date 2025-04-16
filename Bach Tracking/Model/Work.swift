import SwiftData
import UniformTypeIdentifiers

@Model
class Work: Identifiable {
    var id: UUID
    var name: String
    var detail: String
    var opus: String
    var catalogue: String
    var form: MusicalForm?
    var tonality: Tonality?
    var nickname: String
    var number: String
    var composer: Composer
    var instruments: String
    @Relationship(inverse: \Performance.work)
    var performances: [Performance] = []

    @Transient var primaryTitle: String {
        name.isEmpty ? derivedTitle : name
    }

    @Transient var derivedTitle: String {
        var derivedTitle: String = ""

        if self.form != nil {
            derivedTitle += "\(self.form!.name) "
        }

        if !self.instruments.isEmpty {
            derivedTitle += " para \(self.instruments) "
        }

        if !self.number.isEmpty {
            derivedTitle += " n.º \(self.number) "
        }

        if self.tonality != nil {
            derivedTitle += " em \(self.tonality!.rawValue) "
        }

        if !self.opus.isEmpty {
            derivedTitle += ", Op. \(self.opus) "
        }

        if !self.catalogue.isEmpty {
            derivedTitle += ", \(self.catalogue) "
        }

        if !self.nickname.isEmpty {
            derivedTitle += ", “\(self.nickname)” "
        }

        if !derivedTitle.isEmpty {
            derivedTitle =
                derivedTitle
                .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
                .replacingOccurrences(of: " ,", with: ",")

            if derivedTitle.hasPrefix(", ") {
                derivedTitle.removeFirst(2)
            }
        }

        return derivedTitle
    }

    init(
        id: UUID = UUID(), name: String, detail: String, opus: String, catalogue: String,
        form: MusicalForm?, tonality: Tonality?, nickname: String, number: String,
        composer: Composer, instruments: String
    ) {
        self.id = id
        self.name = name
        self.detail = detail
        self.opus = opus
        self.catalogue = catalogue
        self.form = form
        self.tonality = tonality
        self.nickname = nickname
        self.number = number
        self.composer = composer
        self.instruments = instruments
    }

    func hasDerivedTitle() -> Bool {
        return derivedTitle != primaryTitle && !derivedTitle.isEmpty
    }

    enum Tonality: String, CaseIterable, Identifiable, Codable {
        case c = "Dó maior"
        case a = "Lá maior"
        case eb = "Mi bemol maior"

        var id: String { self.rawValue }
    }
}
