import Testing
import Foundation
import UIKit
@testable import ImageCacheKit

@Suite("MemoryCacheTests")
struct MemoryCacheTests {
    
    let memoryCache: MemoryCache
    let testURL = URL(string: "https://example.com/image.png")!
    
    init() {
        memoryCache = MemoryCache(
            config: CacheConfig(
                memoryCacheCountLimit: 2,
                memoryCacheSizeLimit: 50_000_000,
                diskCacheExpiration: 60 * 60 * 24,
                diskCacheSizeLimit: nil
            )
        ) // Memory cache configurations
    }
    
    @Test
    func testStoreAndRetrieveImage() async {
        let image = UIImage(systemName: "star")!
        await memoryCache.store(image: image, for: testURL)
        
        let cachedImage = await memoryCache.image(for: testURL)
        #expect(cachedImage != nil)
    }
    
    @Test
    func testExpiredImageReturnsNil() async {
        let image = UIImage(systemName: "star")!
        let expiredDate = Date().addingTimeInterval(-3600)
        await memoryCache.store(image: image, for: testURL, expirationDate: expiredDate)
        
        let result = await memoryCache.image(for: testURL)
        #expect(result == nil)
    }
    
    @Test
    func testClearCacheWhenLimitExceeded() async {
        let image = UIImage(systemName: "star")!
        
        let urls = [
            URL(string: "https://example.com/1.png")!,
            URL(string: "https://example.com/2.png")!,
            URL(string: "https://example.com/3.png")!
        ]
        
        for url in urls {
            await memoryCache.store(image: image, for: url)
        }
        
        let image1 = await memoryCache.image(for: urls[0])
        let image2 = await memoryCache.image(for: urls[1])
        let image3 = await memoryCache.image(for: urls[2])
        
        let hitCount = [image1, image2, image3].compactMap { $0 }.count
        #expect(hitCount <= 2)
    }
    
    @Test
    func testClear() async throws {
        let image = UIImage(systemName: "star")!
        await memoryCache.store(image: image, for: testURL)
        
        await memoryCache.clear()
        let result = await memoryCache.image(for: testURL)
        #expect(result == nil)
    }
}
