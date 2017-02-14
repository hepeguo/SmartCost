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
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(1.0)
        context?.setStrokeColor(UIColor.gray.cgColor)
        let dashArray: [CGFloat] = [1, 1]
//        CGContextSetLineDash(context, 0, dashArray, 2)
        context?.setLineDash(phase: 2, lengths: dashArray)
        context?.move(to: CGPoint(x: 0, y: 0))
        context?.addLine(to: CGPoint(x: bounds.width, y: 0))
        context?.strokePath()
    }
}
