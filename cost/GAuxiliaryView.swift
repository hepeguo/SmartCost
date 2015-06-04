//
//  GAuxiliaryView.swift
//  calendar
//
//  Created by 郭振永 on 15/5/2.
//  Copyright (c) 2015年 guozy. All rights reserved.
//

import UIKit

class GAuxiliaryView: UIView {
    var shape: GShape!
    var strokeColor: UIColor! {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var fillColor: UIColor! {
        didSet {
            setNeedsDisplay()
        }
    }
    
    let defaultFillColor = UIColor.colorFromCode(0xe74c3c)
    
    private var radius: CGFloat {
        get {
            return (min(frame.height, frame.width) - 10) / 2
        }
    }
    
    init(rect: CGRect, shape: GShape) {
        self.shape = shape
        super.init(frame: rect)
        strokeColor = UIColor.clearColor()
        fillColor = UIColor.colorFromCode(0xe74c3c)
        
        layer.cornerRadius = 5
        backgroundColor = .clearColor()
    }
    
    override func didMoveToSuperview() {
        setNeedsDisplay()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        var path: UIBezierPath!
        
        if let shape = shape {
            switch shape {
            case .RightFlag: path = rightFlagPath()
            case .LeftFlag: path = leftFlagPath()
            case .Circle: path = circlePath()
            case .Rect: path = rectPath()
            }
        }
        
        strokeColor.setStroke()
        fillColor.setFill()
        
        if let path = path {
            path.lineWidth = 1
            path.stroke()
            path.fill()
        }
    }
    
    deinit {
        //println("[CVCalendar Recovery]: AuxiliaryView is deinited.")
    }
}

extension GAuxiliaryView {
    func updateFrame(frame: CGRect) {
        self.frame = frame
        setNeedsDisplay()
    }
}

extension GAuxiliaryView {
    func circlePath() -> UIBezierPath {
        let arcCenter = CGPointMake(frame.width / 2, frame.height / 2)
        let startAngle = CGFloat(0)
        let endAngle = CGFloat(M_PI * 2.0)
        let clockwise = true
        
        let path = UIBezierPath(arcCenter: arcCenter, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: clockwise)
        
        return path
        
    }
    
    func rightFlagPath() -> UIBezierPath {
        let flag = UIBezierPath()
        flag.moveToPoint(CGPointMake(bounds.width / 2, bounds.height / 2 - radius))
        flag.addLineToPoint(CGPointMake(bounds.width, bounds.height / 2 - radius))
        flag.addLineToPoint(CGPointMake(bounds.width, bounds.height / 2 + radius ))
        flag.addLineToPoint(CGPointMake(bounds.width / 2, bounds.height / 2 + radius))
        
        var path = CGPathCreateMutable()
        CGPathAddPath(path, nil, circlePath().CGPath)
        CGPathAddPath(path, nil, flag.CGPath)
        
        return UIBezierPath(CGPath: path)
    }
    
    func leftFlagPath() -> UIBezierPath {
        let flag = UIBezierPath()
        flag.moveToPoint(CGPointMake(bounds.width / 2, bounds.height / 2 + radius))
        flag.addLineToPoint(CGPointMake(0, bounds.height / 2 + radius))
        flag.addLineToPoint(CGPointMake(0, bounds.height / 2 - radius))
        flag.addLineToPoint(CGPointMake(bounds.width / 2, bounds.height / 2 - radius))
        
        var path = CGPathCreateMutable()
        CGPathAddPath(path, nil, circlePath().CGPath)
        CGPathAddPath(path, nil, flag.CGPath)
        
        return UIBezierPath(CGPath: path)
    }
    
    func rectPath() -> UIBezierPath {
        let midX = bounds.width / 2
        let midY = bounds.height / 2
        
        let offset:CGFloat = 5.0
        
        let path = UIBezierPath(rect: CGRectMake(0 - offset, midY - radius, bounds.width + offset / 2, radius * 2))
        
        return path
    }
}


extension UIColor {
    class func colorFromCode(code: Int) -> UIColor {
        let red = CGFloat(((code & 0xFF0000) >> 16)) / 255
        let green = CGFloat(((code & 0xFF00) >> 8)) / 255
        let blue = CGFloat((code & 0xFF)) / 255
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
}
