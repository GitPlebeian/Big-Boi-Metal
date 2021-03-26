//
//  UIColor.swift
//  game
//
//  Created by Jackson Tubbs on 11/14/20.
//

import UIKit

extension UIColor {
    static let background1 = UIColor(named: "background1")!
    static let background2 = UIColor(named: "background2")!
    static let background3 = UIColor(named: "background3")!
    static let background4 = UIColor(named: "background4")!
    static let background5 = UIColor(named: "background5")!
    static let background6 = UIColor(named: "background6")!
    static let primary     = UIColor(named: "primary")
    
    static let mapDarkSea        = UIColor(displayP3Red: 14/255,  green: 24/255,  blue: 43/255,  alpha: 1)
    static let mapSuperDeepWater = UIColor(displayP3Red: 16/255,  green: 31/255,  blue: 60/255,  alpha: 1)
    static let mapDeepWater      = UIColor(displayP3Red: 21/255,  green: 39/255,  blue: 76/255,  alpha: 1)
    static let mapWater          = UIColor(displayP3Red: 27/255,  green: 52/255,  blue: 97/255,  alpha: 1)
    static let mapShallowWater   = UIColor(displayP3Red: 40/255,  green: 76/255,  blue: 137/255, alpha: 1)
    static let mapBeach          = UIColor(displayP3Red: 234/255, green: 210/255, blue: 135/255, alpha: 1)
    static let mapGrass          = UIColor(displayP3Red: 107/255, green: 142/255, blue: 39/255,  alpha: 1)
    static let mapForest         = UIColor(displayP3Red: 72/255,  green: 111/255, blue: 37/255,  alpha: 1)
    static let mapMountain1      = UIColor(displayP3Red: 30/255,  green: 30/255,  blue: 30/255,  alpha: 1)
    static let mapMountain2      = UIColor(displayP3Red: 55/255,  green: 47/255,  blue: 38/255,  alpha: 1)
    static let mapMountain3      = UIColor(displayP3Red: 65/255,  green: 54/255,  blue: 46/255,  alpha: 1)
    static let mapMountain4      = UIColor(displayP3Red: 70/255,  green: 64/255,  blue: 59/255,  alpha: 1)
    static let mapSnow           = UIColor(displayP3Red: 236/255, green: 236/255, blue: 236/255, alpha: 1)
    
    var allValues: [Float] {
        var colors: [Float] = []
        colors.append(Float(CIColor(color: self).red))
        colors.append(Float(CIColor(color: self).green))
        colors.append(Float(CIColor(color: self).blue))
        return colors
    }
    
    var redValue: CGFloat{ return CIColor(color: self).red }
    var greenValue: CGFloat{ return CIColor(color: self).green }
    var blueValue: CGFloat{ return CIColor(color: self).blue }
    var alphaValue: CGFloat{ return CIColor(color: self).alpha }
}
