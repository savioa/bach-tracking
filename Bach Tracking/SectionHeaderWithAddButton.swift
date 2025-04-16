import SwiftUI

struct SectionHeaderWithAddButton: View {
    let sectionHeaderText: String
    let accessibilityLabel: String
    @Binding var isAdding: Bool

    var body: some View {
        HStack {
            Text(sectionHeaderText)
            Spacer()
            Button(action: { isAdding = true }) { Image(systemName: "plus") }
                .buttonStyle(.borderless)
                .accessibilityLabel(accessibilityLabel)
        }
    }
}
