import CoreSpotlight
import SwiftData
import SwiftUI

@main
struct BachTrackingApp: App {
    @StateObject private var spotlightManager = SpotlightNavigationManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(sharedContainer)
                .environmentObject(spotlightManager)
                .onContinueUserActivity(CSSearchableItemActionType) { userActivity in
                    guard
                        let userInfo = userActivity.userInfo,
                        let rawValue = userInfo[CSSearchableItemActivityIdentifier],
                        let idString = rawValue as? String
                    else {
                        return
                    }

                    spotlightManager.navigateToItem(with: idString)
                }
        }
    }
}

let sharedContainer: ModelContainer = {
    let config = ModelConfiguration(
        "BachTrackingModel",
        url: URL.applicationSupportDirectory.appending(path: "BachTracking.sqlite"),
        cloudKitDatabase: .none
    )

    do {
        return try ModelContainer(for: Concert.self, configurations: config)
    } catch {
        fatalError("ModelContainer: \(error)")
    }
}()

final class SpotlightNavigationManager: ObservableObject {
    static let shared = SpotlightNavigationManager()

    @Published var selectedItemId: UUID?
    @Published var selectedItemType: String?

    private init() {}

    func navigateToItem(with id: String) {
        let components = id.split(separator: ".", maxSplits: 1)
        let type = String(components[0])
        let uuidString = String(components[1])

        if let uuid = UUID(uuidString: uuidString) {
            selectedItemId = uuid
            selectedItemType = type
        }
    }
}
