import Foundation
import UIKit

public actor ImageCache {
    private let memoryCache: MemoryCache
    private let diskCache: DiskCache
    private let downloader: ImageDownloader
    
    // Modified singleton pattern
    @MainActor public static var shared: ImageCache {
        get async {
            let instance = await ImageCache(config: .default)
            return instance
        }
    }
    
    public init(config: CacheConfig) async {
        self.memoryCache = MemoryCache(config: config) 
        self.diskCache = await DiskCache(config: config)
        self.downloader = ImageDownloader()
    }
    
    public func image(for url: URL) async throws -> UIImage {
        // Check memory cache first
        if let image = await memoryCache.image(for: url) {
            return image
        }
        
        // Check disk cache
        if let image = await diskCache.image(for: url) {
            // Store in memory cache for future use
            await memoryCache.store(image: image, for: url)
            return image
        }
        
        // Download if not cached
        let image = try await downloader.downloadImage(from: url)
        guard let image = image else {
            throw ImageCacheError.downloadFailed(url: url)
        }
        
        // Store in both caches
        await memoryCache.store(image: image, for: url)
        await diskCache.store(image: image, for: url)
        return image
    }
    
    public func clearCache() async {
        await memoryCache.clear()
        await diskCache.clear()
    }
}
