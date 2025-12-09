//
//  UnsplashService.swift
//  TripSync
//
//  Created on 04/12/25.
//

import UIKit

class UnsplashService {
    
    // MARK: - Singleton
    static let shared = UnsplashService()
    
    // MARK: - Properties
    private let imageCache = NSCache<NSString, UIImage>()
    
    private init() {
        // Configure cache limits
        imageCache.countLimit = 100 // Maximum 100 images in cache
        imageCache.totalCostLimit = 50 * 1024 * 1024 // 50 MB max cache size
    }
    
    // MARK: - Image Loading
    
    /// Load image from URL with caching
    /// - Parameters:
    ///   - urlString: The URL string of the image to load
    ///   - completion: Completion handler with optional UIImage (nil if failed)
    func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        let cacheKey = urlString as NSString
        
        // Check cache first
        if let cachedImage = imageCache.object(forKey: cacheKey) {
            DispatchQueue.main.async {
                completion(cachedImage)
            }
            return
        }
        
        // Validate URL
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }
        
        // Download image
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self,
                  let data = data,
                  error == nil,
                  let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            // Cache the image
            self.imageCache.setObject(image, forKey: cacheKey)
            
            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }
    
    /// Load image from URL with placeholder support
    /// - Parameters:
    ///   - urlString: The URL string of the image to load
    ///   - placeholder: Placeholder image to show while loading
    ///   - imageView: The UIImageView to set the image on
    func loadImage(from urlString: String?, placeholder: UIImage?, into imageView: UIImageView) {
        // Set placeholder immediately
        imageView.image = placeholder
        
        guard let urlString = urlString else {
            return
        }
        
        loadImage(from: urlString) { image in
            imageView.image = image ?? placeholder
        }
    }
    
    /// Clear all cached images
    func clearCache() {
        imageCache.removeAllObjects()
    }
}
