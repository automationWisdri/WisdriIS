//
//  BaseViewController.swift
//  WisdriIS
//
//  Created by Allen on 3/1/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    var animatedOnNavigationBar = true
    
//    var backBarButtonItem = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.whiteColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let navigationController = navigationController else {
            return
        }

        navigationController.navigationBar.backgroundColor = nil
//        navigationController.navigationBar.barTintColor = UIColor.yepTintColor()
        navigationController.navigationBar.translucent = true
        navigationController.navigationBar.shadowImage = nil
        navigationController.navigationBar.barStyle = UIBarStyle.Default
        navigationController.navigationBar.setBackgroundImage(nil, forBarMetrics: UIBarMetrics.Default)
//        backBarButtonItem.title = ""
//        navigationController.navigationItem.backBarButtonItem = backBarButtonItem

        let textAttributes = [
            NSForegroundColorAttributeName: UIColor.yepNavgationBarTitleColor(),
//            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: UIFont.navigationBarTitleFont()
        ]

        navigationController.navigationBar.titleTextAttributes = textAttributes
        navigationController.navigationBar.tintColor = nil

        if navigationController.navigationBarHidden {
            navigationController.setNavigationBarHidden(false, animated: animatedOnNavigationBar)
        }
    }
}

