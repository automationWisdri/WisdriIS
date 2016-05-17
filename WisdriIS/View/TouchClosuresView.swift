//
//  TouchClosuresView.swift
//  WisdriIS
//
//  Created by Allen on 3/10/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit

class TouchClosuresView: UIView {

    var touchesBeganAction: (() -> Void)?
    var touchesEndedAction: (() -> Void)?
    var touchesCancelledAction: (() -> Void)?

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touchesBeganAction?()
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touchesEndedAction?()
    }

    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        touchesCancelledAction?()
    }
}

