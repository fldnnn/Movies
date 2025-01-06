//
//  ImageLoader.swift
//  Movies
//
//  Created by fulden onan on 5.01.2025.
//

import UIKit

final class ImageLoader {
    static let shared = ImageLoader()
    private let cache = NSCache<NSString, UIImage>()

    private init() {}

    func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        // If it is cached already, return
        if let cachedImage = cache.object(forKey: urlString as NSString) {
            completion(cachedImage)
            return
        }

        // Otherwise, download
        guard let url = URL(string: "https://image.tmdb.org/t/p/w500" + urlString) else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self = self else { return }
            guard let data = data, let image = UIImage(data: data) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            // Cache the image
            self.cache.setObject(image, forKey: urlString as NSString)
            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }
}
