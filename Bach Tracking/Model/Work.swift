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
        var parts: [String] = []

        if let form {
            parts.append("\(form.name)")
        }

        if !self.instruments.isEmpty {
            parts.append("para \(self.instruments)")
        }

        if !self.number.isEmpty {
            parts.append("n.º \(self.number)")
        }

        if let tonality {
            parts.append("em \(tonality.rawValue)")
        }

        if !self.opus.isEmpty {
            parts.append(", Op. \(self.opus)")
        }

        if !self.catalogue.isEmpty {
            parts.append(", \(self.catalogue) ")
        }

        if !self.nickname.isEmpty {
            parts.append(", “\(self.nickname)”")
        }

        var derivedTitle = parts.joined(separator: " ")

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
        case cMajor = "Dó maior"
        case aMajor = "Lá maior"
        case ebFlatMajor = "Mi bemol maior"

        var id: String { self.rawValue }
    }
}

struct WorkDTO: Codable {
    var name: String
    var detail: String
    var opus: String
    var catalogue: String
    var form: String?
    var tonality: String?
    var nickname: String
    var number: String
    var composer: ComposerDTO
    var instruments: String

    init(from work: Work) {
        self.name = work.name
        self.detail = work.detail
        self.opus = work.opus
        self.catalogue = work.catalogue
        self.form = work.form?.name
        self.tonality = work.tonality?.rawValue
        self.nickname = work.nickname
        self.number = work.number
        self.composer = ComposerDTO(from: work.composer)
        self.instruments = work.instruments
    }
}
