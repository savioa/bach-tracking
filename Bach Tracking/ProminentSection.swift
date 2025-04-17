import SwiftUI

struct ProminentSection<Content: View>: View {
    private let header: AnyView
    private let content: () -> Content

    init(_ title: String, @ViewBuilder content: @escaping () -> Content) {
        self.header = AnyView(Text(title))
        self.content = content
    }

    init<Header: View>(header: Header, @ViewBuilder content: @escaping () -> Content) {
        self.header = AnyView(header)
        self.content = content
    }

    var body: some View {
        Section(header: header) {
            content()
        }
        .headerProminence(.increased)
    }
}
