//
//  DashLine.swift
//  $Mate
//
//  Created by 郭振永 on 15/4/2.
//  Copyright (c) 2015年 guozy. All rights reserved.
//

import UIKit

class DashLine: UIView {
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        CGContextSetLineWidth(context, 1.0)
        CGContextSetStrokeColorWithColor(context, UIColor.grayColor().CGColor)
        let dashArray: [CGFloat] = [1, 1]
        CGContextSetLineDash(context, 0, dashArray, 2)
        CGContextMoveToPoint(context, 0, 0)
        CGContextAddLineToPoint(context, bounds.width, 0)
        CGContextStrokePath(context)
    }
}
