import UIKit
import Foundation

class CacheEntry {
    let image: UIImage
    let expirationDate: Date?

    init(image: UIImage, expirationDate: Date?) {
        self.image = image
        self.expirationDate = expirationDate
    }

    var isExpired: Bool {
        guard let expirationDate = expirationDate else { return false }
        return Date() > expirationDate
    }
}
