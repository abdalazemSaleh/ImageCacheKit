//
//  ImageCacheError.swift
//  ImageCacheKit
//
//  Created by Abdel Azim Saleh on 31/07/2025.
//


import Foundation

public enum ImageCacheError: Error, LocalizedError {
    case downloadFailed(url: URL)
    case invalidImageData(url: URL)
    case cacheWriteFailed(url: URL)
    case expiredEntry(url: URL)
    case invalidURL(String)
    case memoryPressure
    case diskFull
    
    public var errorDescription: String? {
        switch self {
        case .downloadFailed(let url):
            return String(format: NSLocalizedString(
                "Failed to download image from %@: %@",
                comment: "Download error"),
                url.absoluteString
            )
            
        case .invalidImageData(let url):
            return String(format: NSLocalizedString(
                "Invalid image data received from %@",
                comment: "Data error"),
                url.absoluteString
            )
            
        case .cacheWriteFailed(let url):
            return String(format: NSLocalizedString(
                "Failed to write image to cache for %@",
                comment: "Cache write error"),
                url.absoluteString
            )
            
        case .expiredEntry(let url):
            return String(format: NSLocalizedString(
                "Cached image for %@ has expired",
                comment: "Expiration error"),
                url.absoluteString
            )
            
        case .invalidURL(let urlString):
            return String(format: NSLocalizedString(
                "Invalid URL: %@",
                comment: "URL error"),
                urlString
            )
            
        case .memoryPressure:
            return NSLocalizedString(
                "Memory pressure forced cache clearance",
                comment: "Memory error"
            )
            
        case .diskFull:
            return NSLocalizedString(
                "Disk is full - cannot cache image",
                comment: "Disk space error"
            )
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .downloadFailed, .invalidImageData:
            return NSLocalizedString(
                "Please check your connection and try again",
                comment: "Recovery for network errors"
            )
        case .diskFull:
            return NSLocalizedString(
                "Free up disk space or adjust cache settings",
                comment: "Recovery for disk errors"
            )
        default:
            return NSLocalizedString(
                "Please try again later",
                comment: "Generic recovery"
            )
        }
    }
}
