//
//  KindItemView.swift
//  cost
//
//  Created by 郭振永 on 15/5/13.
//  Copyright (c) 2015年 guozy. All rights reserved.
//

import UIKit

class KindItemView: UIView {
    
    
    var kind: String? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        let imageView = UIImageView(frame: CGRectMake(20, 5, frame.width - 40, frame.width - 40))
        imageView.image = UIImage(named: kind!)
        let nameLabel = UILabel(frame: CGRectMake(0, frame.width - 35, frame.width, 20))
        nameLabel.text = kind
        nameLabel.textColor = UIColor.whiteColor()
        nameLabel.textAlignment = .Center
        nameLabel.font = UIFont(name: "Avenir-Heavy", size: 10)!
        addSubview(imageView)
        addSubview(nameLabel)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(frame: CGRect, kind: String) {
        super.init(frame: frame)
        userInteractionEnabled = true
        self.kind = kind
        backgroundColor = UIColor.clearColor()
    }


    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
