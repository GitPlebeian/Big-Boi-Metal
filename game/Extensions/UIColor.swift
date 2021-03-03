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
