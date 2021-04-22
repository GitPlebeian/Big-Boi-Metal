//
//  SelectMapButton.swift
//  Island Hopper
//
//  Created by Jackson Tubbs on 4/11/21.
//

import UIKit

class SelectMapButton: UIButton {

    var mapName: URL
    
    init(mapName: URL) {
        self.mapName = mapName
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
