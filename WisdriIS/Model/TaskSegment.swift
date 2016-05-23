//
//  TaskSegment.swift
//  WisdriIS
//
//  Created by Alle on 5/23/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import Foundation

let segmentPlaceholder = Segment(id: "0", name: NSLocalizedString("Choose...", comment: ""))

struct Segment: Hashable {
    
    var id: String
    var name: String
    
    var hashValue: Int {
        return id.hashValue
    }
    
}

func ==(lhs: Segment, rhs: Segment) -> Bool {
    return lhs.id == rhs.id
}