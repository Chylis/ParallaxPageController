//
//  UIView+Layout.swift
//  ParallaxPageController
//
//  Created by Magnus Eriksson on 24/08/16.
//  Copyright © 2016 Magnus Eriksson. All rights reserved.
//

import UIKit

extension UIView {
    
    ///Centers the subview in self
    func center(subview: UIView) {
        addSubview(subview)
        
        subview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: subview.centerXAnchor),
            centerYAnchor.constraint(equalTo: subview.centerYAnchor),
            widthAnchor.constraint(equalTo: subview.widthAnchor),
            heightAnchor.constraint(equalTo: subview.heightAnchor)
            ])
    }
}
