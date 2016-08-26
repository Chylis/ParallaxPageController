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
    
    static func make(image: UIImage) -> ImageController {
        return ImageController(image: image)
    }
}

class ImageController: UIViewController {
    
    //MARK: Properties
    
    let image: UIImage
    
    //MARK: Initialisation
    
    init(image: UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Life cycle
    
    override func loadView() {
        self.view = UIImageView(image: image)
    }
}
