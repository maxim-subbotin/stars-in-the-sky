//
//  ColorSchema.swift
//  StarsOnSky
//
//  Created by Max Subbotin on 1/7/20.
//

import Foundation
import UIKit

class ColorSchema {
    public var backgroundColor = UIColor(red:0.07, green:0.27, blue:0.35, alpha:1.0)
    public var skyColor = UIColor(red:0.00, green:0.09, blue:0.12, alpha:1.0)
    public var skyBorderColor = UIColor(red:0.12, green:0.10, blue:0.22, alpha:1.0)
    public var skyLineColor = UIColor(red:0.93, green:0.95, blue:0.95, alpha:1.0)
    
    public static var current: ColorSchema {
        return ColorSchema()
    }
}
