//
//  Kind.swift
//  $Mate
//
//  Created by 郭振永 on 15/4/13.
//  Copyright (c) 2015年 guozy. All rights reserved.
//

import Foundation

class Kind: NSObject {
    var name: String = ""
    var sum: Float = 0.0
    
    override init() {
        super.init()
    }
    
    init(name: String, price: Float) {
        self.name = name
        self.sum = price
    }
}
    