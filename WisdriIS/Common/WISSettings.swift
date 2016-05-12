//
//  WISSettings.swift
//  WisdriIS
//
//  Created by Allen on 1/24/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit

let keyPrefix =  "WISSettings."

class WISSettings: NSObject {
    
    static let sharedInstance = WISSettings()
    
    private override init(){
        super.init()
    }
    
    subscript(key: String) -> String? {
        get {
            return NSUserDefaults.standardUserDefaults().objectForKey(keyPrefix + key) as? String
        }
        set {
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: keyPrefix + key )
        }
    }
    
    func save(){
        NSUserDefaults.standardUserDefaults().synchronize()
    }
}
