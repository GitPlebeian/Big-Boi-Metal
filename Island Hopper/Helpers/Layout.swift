//
//  Layout.swift
//  Island Hopper
//
//  Created by Jackson Tubbs on 4/3/21.
//

import UIKit

class Layout {
    
    // Center View In View
    static func centerViewInView(_ subView: UIView, _ superView: UIView) {
        subView.translatesAutoresizingMaskIntoConstraints = false
        superView.addSubview(subView)
        NSLayoutConstraint.activate([
            subView.centerXAnchor.constraint(equalTo: superView.centerXAnchor),
            subView.centerYAnchor.constraint(equalTo: superView.centerYAnchor)
        ])
    }
    
    // Configure
    static func configureView(subView: UIView, superView: UIView,
                              top topOptional: CGFloat? = nil,
                              leading leadingOptional: CGFloat? = nil,
                              trailing trailingOptional: CGFloat? = nil,
                              bottom bottomOptional: CGFloat? = nil,
                              padding paddingOptional: CGFloat? = nil) {
        
        subView.translatesAutoresizingMaskIntoConstraints = false
        superView.addSubview(subView)
        
        if let _ = paddingOptional {
//            NSLayoutConstraint.activate([
//                subView.topAnchor.constraint(equalTo: superView., constant: <#T##CGFloat#>)
//            ])
        } else {
            if let top = topOptional {
                subView.topAnchor.constraint(equalTo: superView.topAnchor, constant: top).isActive = true
            }
            if let leading = leadingOptional {
                subView.leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: leading).isActive = true
            }
            if let trailing = trailingOptional {
                subView.trailingAnchor.constraint(equalTo: superView.trailingAnchor, constant: trailing).isActive = true
            }
            if let bottom = bottomOptional {
                subView.bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: bottom).isActive = true
            }
        }
    }
}
