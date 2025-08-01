import Foundation
import UIKit

actor MemoryCache {
    private var cache: [URL: CacheEntry] = [:]
    private let config: CacheConfig
    
    init(config: CacheConfig) {
        self.config = config
    }
    
    func image(for url: URL) -> UIImage? {
        guard let entry = cache[url] else { return nil }
        return entry.isExpired ? nil : entry.image
    }
    
    func store(image: UIImage, for url: URL, expirationDate: Date? = nil) {
        let entry = CacheEntry(image: image, expirationDate: expirationDate)
        cache[url] = entry
        
        if cache.count > config.memoryCacheCountLimit {
            cleanUp()
        }
    }
    
    func clear() {
        cache.removeAll()
    }
    
    private func cleanUp() {
        cache = cache.filter { !$0.value.isExpired }
        
        if cache.count > config.memoryCacheCountLimit {
            let sorted = cache.sorted {
                ($0.value.expirationDate ?? .distantFuture) <
                ($1.value.expirationDate ?? .distantFuture)
            }
            cache = Dictionary(
                sorted.prefix(config.memoryCacheCountLimit).map { ($0.key, $0.value) },
                uniquingKeysWith: { first, _ in first }
            )
        }
    }
}
