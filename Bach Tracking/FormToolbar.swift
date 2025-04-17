import SwiftUI

struct FormToolbar {
    @ToolbarContentBuilder
    static func items(
        confirmLabel: String = "Salvar",
        isConfirmDisabled: Bool = false,
        onConfirm: @escaping () -> Void
    ) -> some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            CancelButton()
        }
        ToolbarItem(placement: .confirmationAction) {
            Button(confirmLabel, action: onConfirm)
                .disabled(isConfirmDisabled)
        }
    }

    private struct CancelButton: View {
        @Environment(\.dismiss) private var dismiss

        var body: some View {
            Button("Cancelar") {
                dismiss()
            }
        }
    }
}
