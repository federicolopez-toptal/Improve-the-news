//
//  SocialConnectButton.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 06/04/2022.
//  Copyright © 2022 Mindy Long. All rights reserved.
//

import UIKit

class SocialConnectButton: UIButton {

    private var _connected = false

    public var connected: Bool {
        get {
            return _connected
        } set(value) {
            _connected = value
            self.update()
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.applyStyle()
        self.update()
    }
    
    private func applyStyle() {
        self.layer.cornerRadius = 17
    }
    
    func update() {
        if(_connected) {
            self.setCustomAttributedText("Disconnect")
            self.backgroundColor = accentOrange
        } else {
            self.setCustomAttributedText("Connect")
            self.backgroundColor = .lightGray
        }
    }

}
