//
//  UIImage+Ext.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 26/08/25.
//

import UIKit

extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
