import Foundation

extension Date {
    var dayMonth: String {
        let formatter: DateFormatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "dd 'de' MMMM"
        return formatter.string(from: self)
    }
}