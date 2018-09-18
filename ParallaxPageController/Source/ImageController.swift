//
//  ScrollableImageController.swift
//  ParallaxPageController
//
//  Created by Magnus Eriksson on 23/08/16.
//  Copyright © 2016 Magnus Eriksson. All rights reserved.
//

import Foundation

import UIKit

struct ImageControllerFactory {
    
    static func make(image: UIImage, contentMode: UIView.ContentMode) -> ImageController {
        return ImageController(image: image, contentMode: contentMode)
    }
}

class ImageController: UIViewController {
    
    //MARK: Properties
    
    let image: UIImage
    let contentMode: UIView.ContentMode
    
    //MARK: Initialisation
    
    init(image: UIImage, contentMode: UIView.ContentMode) {
        self.image = image
        self.contentMode = contentMode
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Life cycle
    
    override func loadView() {
        let imageView = UIImageView(image: image)
        imageView.contentMode = contentMode
        self.view = imageView
    }
}
