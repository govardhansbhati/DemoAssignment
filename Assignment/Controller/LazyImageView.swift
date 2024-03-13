//
//  LazyImageView.swift
//  Assignment
//
//  Created by Govardhan Singh on 13/03/24.
//

import UIKit

class LazyImageView: UIImageView {
    
    private let imageCache = NSCache<AnyObject, UIImage>()
    
    func loadImage(fromURL imageURL: URL, placeHolderImage: String) {
        self.image = UIImage(named: placeHolderImage)
        if let cachedImage = self.imageCache.object(forKey: imageURL as AnyObject) {
            self.image = cachedImage
            return
        }
        
        DispatchQueue.global().async {
            [weak self] in
            
            if let imageData = try? Data(contentsOf: imageURL) {
                debugPrint("Image url \(imageURL)")
                if let image = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        debugPrint("Image downloaded ")
                        self?.imageCache.setObject(image, forKey: imageURL as AnyObject)
                        self?.image = image
                    }
                }
            }
        }
    }
}

/* Note: - This code is just to understand lazy loading concept. We can't use for production because if the network speed fluctuates or if the images size is huge then it may happen that in one of the collection cells you may see the image of different news. and its not like that I cannot handle the network fluctuation or image size  I can surely do that but then it can take time to do that code usaully when I want to display images on the table or collection view I prefer a third party with the name SDWebImage. Since it it clearly mentioned that don't use any third party so I have not used */
