//
//  UIImage+Ext.swift
//  Movies
//
//  Created by fulden onan on 5.01.2025.
//

import UIKit

extension UIImage {
    /// Resizes the image so that the minimum dimension is at least `minDimension` (default 600).
    /// Maintains aspect ratio.
    func resizedToMinDimension(_ minDimension: CGFloat = 600) -> UIImage? {
        let originalSize = size
        let minSide = min(originalSize.width, originalSize.height)
        
        // If both width/height >= minDimension, skip resizing
        // (or remove this check if you want to scale up smaller images).
        if minSide >= minDimension {
            return self
        }
        
        let scaleFactor = minDimension / minSide
        let newWidth = originalSize.width * scaleFactor
        let newHeight = originalSize.height * scaleFactor
        let newSize = CGSize(width: newWidth, height: newHeight)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: newSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    /// Converts the image to Base64-encoded JPEG data (quality ~0.8).
    func toBase64String() -> String? {
        guard let jpegData = jpegData(compressionQuality: 0.8) else {
            return nil
        }
        return jpegData.base64EncodedString()
    }
    
    enum Photos {
        static let list = UIImage(systemName: "list.bullet")
        static let grid = UIImage(systemName: "square.grid.2x2")
        static let house = UIImage(systemName: "house")
        static let starFill = UIImage(systemName: "star.fill")
    }
}
