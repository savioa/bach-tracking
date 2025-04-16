import SwiftUI

struct AddButtonToolbarItem: ToolbarContent {
    @Binding var isAdding: Bool

    var body: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button {
                isAdding = true
            } label: {
                Image(systemName: "plus")
            }
        }
    }
}