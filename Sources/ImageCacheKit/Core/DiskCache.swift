import Foundation
import UIKit

actor DiskCache {
    private let fileManager: FileManager
    private let cacheDirectory: URL
    private let config: CacheConfig
    
    init(config: CacheConfig, fileManager: FileManager = .default) async {
        self.config = config
        self.fileManager = fileManager
        
        let directory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        self.cacheDirectory = directory.appendingPathComponent("ImageCacheKit")
        
        await createCacheDirectoryIfNeeded()
        await cleanExpiredFiles()
    }
    
    func image(for url: URL) async -> UIImage? {
        let fileURL = cacheFileURL(for: url)
        
        guard let attributes = try? fileManager.attributesOfItem(atPath: fileURL.path),
              let modificationDate = attributes[.modificationDate] as? Date,
              modificationDate.addingTimeInterval(config.diskCacheExpiration) > Date(),
              let data = try? Data(contentsOf: fileURL),
              let image = UIImage(data: data) else {
            return nil
        }
        
        Task {
            try? fileManager.setAttributes([.modificationDate: Date()], ofItemAtPath: fileURL.path)
        }
        
        return image
    }
    
    func store(image: UIImage, for url: URL) async {
        guard let data = image.pngData() else { return }
        
        let fileURL = cacheFileURL(for: url)
        try? data.write(to: fileURL)
        
        if let sizeLimit = config.diskCacheSizeLimit,
           let currentSize = fileManager.directorySize(at: cacheDirectory),
           currentSize > sizeLimit {
            await cleanOldFiles()
        }
    }
    
    func clear() async {
        try? fileManager.removeItem(at: cacheDirectory)
        await createCacheDirectoryIfNeeded()
    }
    
    private func cacheFileURL(for url: URL) -> URL {
        let filename = url.absoluteString.sha256
        return cacheDirectory.appendingPathComponent(filename)
    }
    
    private func createCacheDirectoryIfNeeded() async {
        guard !fileManager.fileExists(atPath: cacheDirectory.path) else { return }
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    private func cleanExpiredFiles() async {
        fileManager.removeExpiredFiles(
            at: cacheDirectory,
            expiration: config.diskCacheExpiration
        )
    }
    
    private func cleanOldFiles() async {
        guard let files = try? fileManager.contentsOfDirectory(
            at: cacheDirectory,
            includingPropertiesForKeys: [.contentModificationDateKey]
        ) else { return }
        
        let sortedFiles = files.sorted {
            let date1 = (try? $0.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? Date.distantPast
            let date2 = (try? $1.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? Date.distantPast
            return date1 < date2
        }
        
        if let sizeLimit = config.diskCacheSizeLimit {
            var currentSize = fileManager.directorySize(at: cacheDirectory) ?? 0
            var index = 0
            
            while currentSize > sizeLimit && index < sortedFiles.count {
                let fileURL = sortedFiles[index]
                if let fileSize = try? fileURL.resourceValues(forKeys: [.totalFileAllocatedSizeKey])
                    .totalFileAllocatedSize {
                    try? fileManager.removeItem(at: fileURL)
                    currentSize -= fileSize
                }
                index += 1
            }
        }
    }
}
