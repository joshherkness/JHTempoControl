//
//  UIImage+Color.swift
//  JHTempoControlDemo
//
//  Created by Joshua Herkness on 12/24/16.
//  Copyright © 2016 JRH. All rights reserved.
//

import Foundation
import UIKit

/* 
 * Extension to initialize a UIImage from a UIColor
 */
public extension UIImage {
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}
