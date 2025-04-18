import SwiftUI

struct CustomMenuPicker<Item: Identifiable & Hashable>: View {
    let title: String
    let items: [Item]
    @Binding var selection: Item?
    let label: (Item) -> String
    var nilTitle = ""

    var body: some View {
        Menu {
            if !nilTitle.isEmpty {
                Button(nilTitle) { selection = nil }
            }

            if let first = items.first {
                Button(label(first)) { selection = first }
                    .onAppear { UIApplication.shared.dismissKeyboard() }

                ForEach(items.dropFirst()) { item in
                    Button(label(item)) { selection = item }
                }
            }
        } label: {
            HStack {
                Text(selection.map(label) ?? title)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(
                        selection == nil ? Color(uiColor: .placeholderText) : .primary
                    )
                Spacer()
                Image(systemName: "chevron.down")
                    .foregroundColor(Color(uiColor: .placeholderText))
            }
        }
    }
}

extension UIApplication {
    func dismissKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
