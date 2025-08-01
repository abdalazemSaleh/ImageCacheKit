import Testing
import Foundation
import UIKit
@testable import ImageCacheKit

@Suite("DiskCacheTests")
struct DiskCacheTests {
    
    var diskCache: DiskCache
    var testDirectory: URL
    let testURL = URL(string: "https://example.com/image.png")!
    
    init() async {
        testDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let config = CacheConfig(
            memoryCacheCountLimit: 10,
            memoryCacheSizeLimit: 100_000_000,
            diskCacheExpiration: 3600,
            diskCacheSizeLimit: 1_000_000_000
        )
        diskCache = await DiskCache(config: config, fileManager: FileManager.default)
    }
    
    @Test
    func testStoreAndRetrieveImage() async {
        let image = UIImage(systemName: "star")!
        
        await diskCache.store(image: image, for: testURL)
        
        let result = await diskCache.image(for: testURL)
        #expect(result != nil)
    }
    
//    @Test
//    func testExpiredImageReturnsNil() async throws {
//        let image = UIImage(systemName: "star")!
//        
//        await diskCache.store(image: image, for: testURL)
//        
//        // Simulate expiration
//        let fileURL = testDirectory.appendingPathComponent(testURL.absoluteString.sha256)
//        try FileManager.default.setAttributes([.modificationDate: Date.distantPast], ofItemAtPath: fileURL.path)
//        
//        let result = await diskCache.image(for: testURL)
//        #expect(result == nil)
//    }
    
    @Test
    func testClearRemovesAllFiles() async {
        let image = UIImage(systemName: "star")!
        
        await diskCache.store(image: image, for: testURL)
        await diskCache.clear()
        
        let result = await diskCache.image(for: testURL)
        #expect(result == nil)
    }
}
