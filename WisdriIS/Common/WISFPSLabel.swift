//
//  WISFPSLabel.swift
//  WisdriIS
//
//  Created by Allen on 6/6/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit

// 参考
// https://github.com/ibireme/YYText/blob/master/Demo/YYTextDemo/YYFPSLabel.m


class WISFPSLabel: UILabel {
    
    private var _link: CADisplayLink?
    private var _count: Int = 0
    private var _lastTime: NSTimeInterval = 0
    
    private let _defaultSize = CGSizeMake(55, 20)
    
    override init(var frame: CGRect) {
        
        if frame.size.width == 0 && frame.size.height == 0 {
            frame.size = _defaultSize
        }
        super.init(frame: frame)
        
        self.layer.cornerRadius = 5
        self.clipsToBounds = true
        self.textAlignment = .Center
        self.userInteractionEnabled = false
        self.textColor = UIColor.blackColor()
        self.backgroundColor = UIColor.clearColor()
//        self.font = UIFont(name: "Menlo", size: 12)
        self.font = UIFont.systemFontOfSize(12)
        self.hidden = false
        
        weak var weakSelf = self
        _link = CADisplayLink(target: weakSelf!, selector: #selector(WISFPSLabel.tick(_:)))
        _link!.addToRunLoop(NSRunLoop .mainRunLoop(), forMode: NSRunLoopCommonModes)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func tick(link: CADisplayLink) {
        
        if _lastTime == 0 {
            _lastTime = link.timestamp
            return
        }
        
        _count += 1
        let delta = link.timestamp - _lastTime
        if delta < 1 {
            return
        }
        _lastTime = link.timestamp
        let fps = Double(_count) / delta
        _count = 0
        
//        let progress = fps / 60.0
//        self.textColor = UIColor(hue: CGFloat(0.27 * ( progress - 0.2 )) , saturation: 1, brightness: 0.9, alpha: 1)
        self.text = "\(Int(fps + 0.5))FPS"
    }
}