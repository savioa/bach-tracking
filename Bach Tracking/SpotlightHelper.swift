import Foundation

func safeThumbnailData(for name: String) -> Data? {
    guard
        let url: URL = URL(
            string: "https://savioa.github.io/bach-tracking/\(name.normalizedForURL()).jpg")
    else {
        return nil
    }

    return try? Data(contentsOf: url)
}
