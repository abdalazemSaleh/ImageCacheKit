import Foundation
import UIKit

actor ImageDownloader {
    private var tasks: [UUID: Task<UIImage?, Error>] = [:]
    
    func downloadImage(from url: URL) async throws -> UIImage? {
        let taskId = UUID()
        
        let task: Task<UIImage?, Error> = Task {
            let (data, _) = try await URLSession.shared.data(from: url)
            return UIImage(data: data)
        }
        
        tasks[taskId] = task
        defer { tasks[taskId] = nil }
        
        return try await task.value
    }
    
    func cancelTask(_ taskId: UUID) {
        tasks[taskId]?.cancel()
        tasks[taskId] = nil
    }
}
