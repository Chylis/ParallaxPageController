//
//  ScrollableImageController.swift
//  ParallaxPageController
//
//  Created by Magnus Eriksson on 23/08/16.
//  Copyright © 2016 Magnus Eriksson. All rights reserved.
//

import Foundation

import UIKit

struct ScrollableImageControllerFactory {
    
    static func make(image: UIImage) -> ScrollableImageController {
        let nib = UINib(nibName: String(describing: ScrollableImageController.self),
                        bundle: Bundle(for: ScrollableImageController.self))
            .instantiate(withOwner: nil, options: nil)
        
        let vc = nib.first as! ScrollableImageController
        vc.image = image
        return vc
    }
}


class ScrollableImageController: UIViewController {
    
    //MARK: IBOutlets
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    //MARK: Properties
    
    private let imageTag = 123
    
    var image: UIImage! {
        willSet {
            contentView.viewWithTag(imageTag)?.removeFromSuperview()
        }
        didSet {
            let imageView = UIImageView(image: image)
            imageView.tag = imageTag
            contentView.center(subview: imageView)
        }
    }
}
