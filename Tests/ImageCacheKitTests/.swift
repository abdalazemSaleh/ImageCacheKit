import Foundation
import UIKit
@testable import ImageCacheKit

class MockImageDownloader: ImageDownloader {
    let mockImage: UIImage?
    init(mockImage: UIImage?) {
        self.mockImage = mockImage
    }
    override func downloadImage(from url: URL) async throws -> UIImage? {
        return mockImage
    }
}
