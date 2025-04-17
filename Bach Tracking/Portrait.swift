import NukeUI
import SwiftUI

struct Portrait: View {
    @State private var hasFailed = false

    var name: String

    var body: some View {
        if !hasFailed {
            LazyImage(
                url: URL(
                    string:
                        "https://savioa.github.io/bach-tracking/\(name.normalizedForURL()).jpg"
                )
            ) { state in
                if let image: Image = state.image {
                    image
                        .resizable()
                        .scaledToFill()
                        .clipShape(Circle())
                        .frame(width: 200, height: 200)
                        .overlay(Circle().stroke(Color.primary.opacity(0.2), lineWidth: 2))
                        .frame(maxWidth: .infinity, alignment: .center)
                } else if state.error != nil {
                    Color.clear
                        .frame(width: 0, height: 0)
                        .onAppear {
                            hasFailed = true
                        }
                } else {
                    ProgressView()
                        .frame(width: 200, height: 200)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .listRowSeparator(.hidden)
        }
    }
}
