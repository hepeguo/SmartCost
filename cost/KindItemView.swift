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
    
    var imageName: String? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var imageView: UIImageView?
    var nameLabel: UILabel?
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        if imageView == nil {
            imageView = UIImageView(frame: CGRectMake(20, 20, frame.width - 40, frame.width - 40))
            addSubview(imageView!)
        }
        imageView!.image = UIImage(named: imageName!)
        if (kind != nil) {
            if nameLabel == nil {
                nameLabel = UILabel(frame: CGRectMake(0, frame.width - 35, frame.width, 20))
                nameLabel!.textColor = UIColor.whiteColor()
                nameLabel!.textAlignment = .Center
                nameLabel!.font = UIFont(name: "Avenir-Heavy", size: 10)!
                addSubview(nameLabel!)
            }
            nameLabel!.text = kind
            
            imageView!.frame = CGRectMake(20, 5, frame.width - 40, frame.width - 40)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(frame: CGRect, kind: String, imageName: String) {
        super.init(frame: frame)
        userInteractionEnabled = true
        self.kind = kind
        self.imageName = imageName
        
        backgroundColor = UIColor.clearColor()
    }
    
    init(frame: CGRect, imageName: String) {
        super.init(frame: frame)
        userInteractionEnabled = true        
        self.imageName = imageName
        
        backgroundColor = UIColor.clearColor()
    }


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
