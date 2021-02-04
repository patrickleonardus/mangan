//
//  LoadImageFromUrl.swift
//  Mangan
//
//  Created by Patrick Leonardus on 14/01/21.
//

import UIKit

extension UIImageView {
    public func imageFromServerURL(urlString: String) {
        self.image = nil
        let urlStringNew = urlString.replacingOccurrences(of: " ", with: "%20")
        URLSession.shared.dataTask(with: NSURL(string: urlStringNew)! as URL, completionHandler: { (data, response, error) -> Void in
            
            if error != nil {
                print(error as Any)
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                let image = UIImage(data: data!)
                self.image = image
                
                UIView.animate(withDuration: 0.5) {
                    self.alpha = 1
                }
                
            })
            
        }).resume()
    }}
