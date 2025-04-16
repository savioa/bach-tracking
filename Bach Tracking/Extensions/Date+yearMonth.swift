import Foundation

extension Date {
    var yearMonth: Int {
        (Calendar.current.component(.year, from: self) * 100)
            + Calendar.current.component(.month, from: self)
    }
}
