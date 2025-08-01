import Foundation

extension FileManager {
    func directorySize(at url: URL) -> Int? {
        guard let enumerator = enumerator(
            at: url,
            includingPropertiesForKeys: [.totalFileAllocatedSizeKey],
            options: []
        ) else { return nil }
        
        var totalSize = 0
        for case let fileURL as URL in enumerator {
            guard let fileSize = try? fileURL.resourceValues(forKeys: [.totalFileAllocatedSizeKey])
                .totalFileAllocatedSize else { continue }
            totalSize += fileSize
        }
        return totalSize
    }
    
    func removeExpiredFiles(at url: URL, expiration: TimeInterval) {
        guard let enumerator = enumerator(
            at: url,
            includingPropertiesForKeys: [.contentModificationDateKey],
            options: []
        ) else { return }
        
        let expirationDate = Date().addingTimeInterval(-expiration)
        
        for case let fileURL as URL in enumerator {
            guard let modificationDate = try? fileURL.resourceValues(forKeys: [.contentModificationDateKey])
                .contentModificationDate else { continue }
            
            if modificationDate < expirationDate {
                try? removeItem(at: fileURL)
            }
        }
    }
}
