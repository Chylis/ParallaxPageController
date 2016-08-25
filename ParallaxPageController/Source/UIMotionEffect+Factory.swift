//
//  UIMotionEffect+Factory.swift
//  ParallaxPageController
//
//  Created by Magnus Eriksson on 25/08/16.
//  Copyright © 2016 Magnus Eriksson. All rights reserved.
//

import Foundation

extension UIMotionEffect {
    
    class func make(strength: Int, type: UIInterpolatingMotionEffectType) -> UIInterpolatingMotionEffect {
            let keyPath = type == .tiltAlongHorizontalAxis ? "center.x" : "center.y"
            let motion = UIInterpolatingMotionEffect(keyPath: keyPath, type: type)
            motion.minimumRelativeValue = -strength
            motion.maximumRelativeValue = strength
            return motion
        }
}
