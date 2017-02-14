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
    override func draw(_ rect: CGRect) {
        if imageView == nil {
            imageView = UIImageView(frame: CGRect(x: 20, y: 20, width: frame.width - 40, height: frame.width - 40))
            addSubview(imageView!)
        }
        imageView!.image = UIImage(named: imageName!)
        if (kind != nil) {
            if nameLabel == nil {
                nameLabel = UILabel(frame: CGRect(x: 0, y: frame.width - 35, width: frame.width, height: 20))
                nameLabel!.textColor = UIColor.white
                nameLabel!.textAlignment = .center
                nameLabel!.font = UIFont(name: "Avenir-Heavy", size: 10)!
                addSubview(nameLabel!)
            }
            nameLabel!.text = kind
            
            imageView!.frame = CGRect(x: 20, y: 5, width: frame.width - 40, height: frame.width - 40)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(frame: CGRect, kind: String, imageName: String) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
        self.kind = kind
        self.imageName = imageName
        
        backgroundColor = UIColor.clear
    }
    
    init(frame: CGRect, imageName: String) {
        super.init(frame: frame)
        isUserInteractionEnabled = true        
        self.imageName = imageName
        
        backgroundColor = UIColor.clear
    }


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
