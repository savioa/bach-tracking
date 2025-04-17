import SwiftUI

struct EditButtonToolbarItem: ToolbarContent {
    @Binding var isEditing: Bool

    var body: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button("Editar") { isEditing = true }
        }
    }
}
