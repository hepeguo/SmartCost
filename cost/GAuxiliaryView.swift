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
    
    fileprivate var radius: CGFloat {
        get {
            return (min(frame.height, frame.width) - 10) / 2
        }
    }
    
    init(rect: CGRect, shape: GShape) {
        self.shape = shape
        super.init(frame: rect)
        strokeColor = UIColor.clear
        fillColor = UIColor.colorFromCode(0xe74c3c)
        
        layer.cornerRadius = 5
        backgroundColor = .clear
    }
    
    override func didMoveToSuperview() {
        setNeedsDisplay()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        _ = UIGraphicsGetCurrentContext()
        var path: UIBezierPath!
        
        if let shape = shape {
            switch shape {
            case .rightFlag: path = rightFlagPath()
            case .leftFlag: path = leftFlagPath()
            case .circle: path = circlePath()
            case .rect: path = rectPath()
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
    func updateFrame(_ frame: CGRect) {
        self.frame = frame
        setNeedsDisplay()
    }
}

extension GAuxiliaryView {
    func circlePath() -> UIBezierPath {
        let arcCenter = CGPoint(x: frame.width / 2, y: frame.height / 2)
        let startAngle = CGFloat(0)
        let endAngle = CGFloat(M_PI * 2.0)
        let clockwise = true
        
        let path = UIBezierPath(arcCenter: arcCenter, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: clockwise)
        
        return path
        
    }
    
    func rightFlagPath() -> UIBezierPath {
        let flag = UIBezierPath()
        flag.move(to: CGPoint(x: bounds.width / 2, y: bounds.height / 2 - radius))
        flag.addLine(to: CGPoint(x: bounds.width, y: bounds.height / 2 - radius))
        flag.addLine(to: CGPoint(x: bounds.width, y: bounds.height / 2 + radius ))
        flag.addLine(to: CGPoint(x: bounds.width / 2, y: bounds.height / 2 + radius))
        
        let path = CGMutablePath()
        path.addPath(circlePath().cgPath)
        path.addPath(flag.cgPath)
//        CGPathAddPath(path, nil, circlePath().cgPath)
//        CGPathAddPath(path, nil, flag.cgPath)
        
        return UIBezierPath(cgPath: path)
    }
    
    func leftFlagPath() -> UIBezierPath {
        let flag = UIBezierPath()
        flag.move(to: CGPoint(x: bounds.width / 2, y: bounds.height / 2 + radius))
        flag.addLine(to: CGPoint(x: 0, y: bounds.height / 2 + radius))
        flag.addLine(to: CGPoint(x: 0, y: bounds.height / 2 - radius))
        flag.addLine(to: CGPoint(x: bounds.width / 2, y: bounds.height / 2 - radius))
        
        let path = CGMutablePath()
        path.addPath(circlePath().cgPath)
        path.addPath(flag.cgPath)
//        CGPathAddPath(path, nil, circlePath().cgPath)
//        CGPathAddPath(path, nil, flag.cgPath)
        
        return UIBezierPath(cgPath: path)
    }
    
    func rectPath() -> UIBezierPath {
        _ = bounds.width / 2
        let midY = bounds.height / 2
        
        let offset:CGFloat = 5.0
        
        let path = UIBezierPath(rect: CGRect(x: 0 - offset, y: midY - radius, width: bounds.width + offset / 2, height: radius * 2))
        
        return path
    }
}


extension UIColor {
    class func colorFromCode(_ code: Int) -> UIColor {
        let red = CGFloat(((code & 0xFF0000) >> 16)) / 255
        let green = CGFloat(((code & 0xFF00) >> 8)) / 255
        let blue = CGFloat((code & 0xFF)) / 255
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
}
