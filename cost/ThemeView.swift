//
//  ThemeView.swift
//  cost
//
//  Created by 郭振永 on 15/6/27.
//  Copyright (c) 2015年 guozy. All rights reserved.
//

import UIKit

class ThemeView: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    var name: String = "origin"
    var color: UIColor = UIColor(red: 244 / 255, green: 111 / 255, blue: 102 / 255, alpha: 1)
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    init(frame: CGRect, name: String, color: UIColor) {
        super.init(frame: frame)
        self.name = name
        self.color = color
        backgroundColor = color
        layer.cornerRadius = 5
    }
    
    func addBorder() {
        layer.borderColor = UIColor.whiteColor().CGColor
        layer.borderWidth = 2
    }
    
    func removeBorder() {
        layer.borderWidth = 0
        layer.borderColor = UIColor.clearColor().CGColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
