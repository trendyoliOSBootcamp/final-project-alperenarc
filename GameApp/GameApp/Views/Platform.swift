//
//  Platform.swift
//  GameApp
//
//  Created by Alperen Arıcı on 24.05.2021.
//

import UIKit


final class Platform: NibView {
    @IBOutlet private weak var platformName: UILabel!
    
    func configure(name: String) {
        platformName.text = name
    }
}
