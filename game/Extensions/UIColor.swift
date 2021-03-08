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
//    static let systemRed = UIColor(named: "background1")!
    
    static let mapDeepWater = UIColor(displayP3Red: 22/255,  green: 49/255,  blue: 218/255, alpha: 1)
    static let mapWater     = UIColor(displayP3Red: 14/255,  green: 97/255,  blue: 255/255, alpha: 1)
    static let mapBeach     = UIColor(displayP3Red: 227/255, green: 237/255, blue: 124/255, alpha: 1)
    static let mapGrass     = UIColor(displayP3Red: 86/255,  green: 236/255, blue: 40/255, alpha: 1)
    static let mapForest    = UIColor(displayP3Red: 39/255,  green: 170/255, blue: 64/255,  alpha: 1)
    static let mapDirt      = UIColor(displayP3Red: 147/255, green: 102/255, blue: 0/255, alpha: 1)
    static let mapMountain  = UIColor(displayP3Red: 91/255,  green: 72/255,  blue: 16/255, alpha: 1)
    static let mapSnow      = UIColor(displayP3Red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
    
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
