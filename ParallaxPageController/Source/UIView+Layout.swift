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
            subview.centerXAnchor.constraint(equalTo: centerXAnchor),
            subview.centerYAnchor.constraint(equalTo: centerYAnchor),
            subview.widthAnchor.constraint(equalTo: widthAnchor),
            subview.heightAnchor.constraint(equalTo: heightAnchor)
            ])
    }
}
