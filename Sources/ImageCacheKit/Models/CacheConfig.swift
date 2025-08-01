import Foundation

public struct CacheConfig: Sendable {
    public let memoryCacheCountLimit: Int
    public let memoryCacheSizeLimit: Int
    public let diskCacheExpiration: TimeInterval
    public let diskCacheSizeLimit: Int?

    @MainActor public static let `default` = CacheConfig(
        memoryCacheCountLimit: 100,
        memoryCacheSizeLimit: 50 * 1024 * 1024, // 50MB
        diskCacheExpiration: 60 * 60 * 24 * 7, // 1 week
        diskCacheSizeLimit: 500 * 1024 * 1024 // 500MB
    )

    public init(
        memoryCacheCountLimit: Int,
        memoryCacheSizeLimit: Int,
        diskCacheExpiration: TimeInterval,
        diskCacheSizeLimit: Int?
    ) {
        self.memoryCacheCountLimit = memoryCacheCountLimit
        self.memoryCacheSizeLimit = memoryCacheSizeLimit
        self.diskCacheExpiration = diskCacheExpiration
        self.diskCacheSizeLimit = diskCacheSizeLimit
    }
}
