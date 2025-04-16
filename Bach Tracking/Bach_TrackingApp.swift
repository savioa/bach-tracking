import CoreSpotlight
import SwiftData
import SwiftUI

@main
struct Bach_TrackingApp: App {
    @StateObject private var spotlightManager: SpotlightNavigationManager =
        SpotlightNavigationManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(sharedContainer)
                .environmentObject(spotlightManager)
                .onContinueUserActivity(CSSearchableItemActionType) { userActivity in
                    if let idString: String = userActivity.userInfo?[
                        CSSearchableItemActivityIdentifier]
                        as? String
                    {
                        spotlightManager.navigateToItem(with: idString)
                    }
                }
        }
    }
}

let sharedContainer: ModelContainer = {
    let config: ModelConfiguration = ModelConfiguration(
        "BachTrackingModel",
        url: URL.applicationSupportDirectory.appending(path: "BachTracking.sqlite"),
        cloudKitDatabase: .none
    )

    return try! ModelContainer(for: Concert.self, configurations: config)
}()

final class SpotlightNavigationManager: ObservableObject {
    static let shared: SpotlightNavigationManager = SpotlightNavigationManager()

    @Published var selectedItemId: UUID? = nil
    @Published var selectedItemType: String? = nil

    private init() {}

    func navigateToItem(with id: String) {
        let components: [String.SubSequence] = id.split(separator: ".", maxSplits: 1)
        let type: String = String(components[0])
        let uuidString: String = String(components[1])

        if let uuid: UUID = UUID(uuidString: uuidString) {
            selectedItemId = uuid
            selectedItemType = type
        }
    }
}
