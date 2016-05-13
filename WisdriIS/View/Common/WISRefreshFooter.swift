//
//  V2RefreshFooter.swift
//  WIS-Swift
//
//  Created by huangfeng on 3/1/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
import MJRefresh
//import KVOController

class WISRefreshFooter: MJRefreshAutoFooter {

    var loadingView:UIActivityIndicatorView?
    var stateLabel:UILabel?
    
    var centerOffset:CGFloat = 0
    
    private var _noMoreDataStateString:String?
    var noMoreDataStateString:String? {
        get{
            return self._noMoreDataStateString
        }
        set{
            self._noMoreDataStateString = newValue
            self.stateLabel?.text = newValue
        }
    }
    
    override var state:MJRefreshState{
        didSet{
            switch state {
            case .Idle:
                self.stateLabel?.text = nil
                self.loadingView?.hidden = true
                self.loadingView?.stopAnimating()
            case .Refreshing:
                self.stateLabel?.text = nil
                self.loadingView?.hidden = false
                self.loadingView?.startAnimating()
            case .NoMoreData:
                self.stateLabel?.text = self.noMoreDataStateString
                self.loadingView?.hidden = true
                self.loadingView?.stopAnimating()
            default:break
            }
        }
    }
    
    /**
     初始化工作
     */
    override func prepare() {
        super.prepare()
        self.mj_h = 50
        
        self.loadingView = UIActivityIndicatorView(activityIndicatorStyle: .White)
        self.addSubview(self.loadingView!)
        
        self.stateLabel = UILabel(frame: CGRectMake(0, 0, 300, 40))
        self.stateLabel?.textAlignment = .Center
        self.stateLabel!.font = wisFont(12)
        self.addSubview(self.stateLabel!)
        
        self.noMoreDataStateString = "没有更多数据了"
        
//        self.KVOController.observe(WISColor.sharedInstance, keyPath: "style", options: [.Initial,.New]) {[weak self] (nav, color, change) -> Void in
//            if WISColor.sharedInstance.style == WISColor.WISColorStyleDefault {
//                self?.loadingView?.activityIndicatorViewStyle = .Gray
//                self?.stateLabel!.textColor = UIColor(white: 0, alpha: 0.3)
//            }
//            else{
//                self?.loadingView?.activityIndicatorViewStyle = .White
//                self?.stateLabel!.textColor = UIColor(white: 1, alpha: 0.3)
//            }
//        }
        self.loadingView?.activityIndicatorViewStyle = .Gray
        self.stateLabel!.textColor = UIColor(white: 0, alpha: 0.3)
    }
    
    /**
     在这里设置子控件的位置和尺寸
     */
    override func placeSubviews(){
        super.placeSubviews()
        self.loadingView!.center = CGPointMake(self.mj_w/2, self.mj_h/2 + self.centerOffset);
        self.stateLabel!.center = CGPointMake(self.mj_w/2, self.mj_h/2  + self.centerOffset);
    }

}
