import Foundation
import SwiftUI

protocol Nameable: Identifiable {
    var name: String { get set }

    init(name: String)

    func getUsageLinks() -> [AnyView]
    func getUsageCount() -> Int

    static var pluralFormItemName: String { get }
    static var newItemLabel: String { get }
    static var dependentItemName: String { get }
}

extension ArtistType {
    static var pluralFormItemName: String { "Tipos de Artista" }
    static var newItemLabel: String { "Novo Tipo de Artista" }
    static var dependentItemName: String { "Artistas" }

    func getUsageLinks() -> [AnyView] {
        var links: [AnyView] = []

        artists.sorted { $0.name < $1.name }.forEach { artist in
            links.append(
                AnyView(
                    NavigationLink {
                        ArtistDetail(artist: artist)
                    } label: {
                        MultilineRow(firstLine: Text(artist.name))
                    }))
        }

        return links
    }
}

extension Series {
    static var pluralFormItemName: String { "Séries" }
    static var newItemLabel: String { "Nova Série" }
    static var dependentItemName: String { "Concertos" }

    func getUsageLinks() -> [AnyView] {
        var links: [AnyView] = []

        concerts.sorted { $0.date > $1.date }.forEach { concert in
            links.append(
                AnyView(
                    NavigationLink {
                        ConcertDetail(concert: concert)
                    } label: {
                        MultilineConcertRow(concert: concert)
                    }))
        }

        return links
    }
}

extension MusicalForm {
    static var pluralFormItemName: String { "Formas" }
    static var newItemLabel: String { "Nova Forma" }
    static var dependentItemName: String { "Obras" }

    func getUsageLinks() -> [AnyView] {
        var links: [AnyView] = []

        works.sorted { $0.primaryTitle < $1.primaryTitle }.forEach { work in
            links.append(
                AnyView(
                    NavigationLink {
                        WorkDetail(work: work)
                    } label: {
                        MultilineRow(
                            firstLine: Text(work.primaryTitle),
                            secondLine: Text(work.composer.shortName))
                    }))
        }

        return links
    }
}

extension Venue {
    static var pluralFormItemName: String { "Locais" }
    static var newItemLabel: String { "Novo Local" }
    static var dependentItemName: String { "Concertos" }

    func getUsageLinks() -> [AnyView] {
        var links: [AnyView] = []

        concerts.sorted { $0.date > $1.date }.forEach { concert in
            links.append(
                AnyView(
                    NavigationLink {
                        ConcertDetail(concert: concert)
                    } label: {
                        MultilineConcertRow(concert: concert)
                    }))
        }

        return links
    }
}
