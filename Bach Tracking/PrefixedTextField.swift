import SwiftUI

struct PrefixedTextField: View {
    let prefix: String
    let placeholder: String
    @Binding var text: String
    var capitalization: TextInputAutocapitalization = .sentences

    var body: some View {
        HStack {
            if !text.isEmpty {
                Text(prefix)
                    .foregroundColor(.primary)
            }

            TextField(placeholder, text: $text)
                .textInputAutocapitalization(capitalization)
                .disableAutocorrection(true)
        }
    }
}
