//
//  CounterView.swift
//  $Mate
//
//  Created by 郭振永 on 15/3/24.
//  Copyright (c) 2015年 guozy. All rights reserved.
//

import UIKit

let PI:CGFloat = CGFloat(M_PI)

class CounterView: UIView {
    var numbers: [Kind] = [Kind()] {
        didSet {
            setNeedsDisplay()
        }
    }
    var label: UILabel?
//    var colors = [UIColor.purpleColor(), UIColor.blueColor(), UIColor.brownColor(), UIColor.yellowColor()]
    var colors = [0xe44B7D3, 0xeE42B6D, 0xeF4E24E, 0xeFE9616, 0xe8AED35,
        0xeff69b4, 0xeba55d3, 0xecd5c5c, 0xeffa500, 0xe40e0d0,
        0xeE95569, 0xeff6347, 0xe7b68ee, 0xe00fa9a, 0xeffd700,
        0xe6699FF, 0xeff6666, 0xe3cb371, 0xeb8860b, 0xe30e0e0, 0xee52c3c, 0xef7b1ab, 0xefa506c, 0xef59288, 0xef8c4d8,
        0xee54f5c, 0xef06d5c, 0xee54f80, 0xef29c9f, 0xeeeb5b7
    ]

    override func draw(_ rect: CGRect) {
        self.layer.sublayers = nil
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2 - 10)
        //width of circle
        let arcWidth: CGFloat = 20
        //inner radius of corcle
        let radius:CGFloat = 70
        let animation: CABasicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = 0.4
        animation.fromValue = 0.0
        animation.toValue = 1.0
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        
//        get every angle of data
        var total: Float = 0.0
        if numbers.count > 0 {
//            var beforeAll = [Float]()
            var num = [Float]()
            for number in numbers {
                num.append(number.sum)
            }
//            for var i = num.count - 1; i >= 0 ; i -= 1 {
//                var before = num[i]
//                for var j = i - 1; j >= 0; j -= 1 {
//                    before += num[j]
//                }
//                num[i] = before
//            }
            var i = num.count
            while i >= 0 {
                var before = num[i]
                var j = i - 1
                while j >= 0 {
                    before += num[j]
                    j -= 1
                }
                num[i] = before
                i -= 1
            }
            
            total = num[num.count - 1]
            
            var angles = [CGFloat]()
            angles.append(0.0)
            for i in 0 ..< num.count - 1 {
                let angle = CGFloat(num[i]) / CGFloat(total) * CGFloat(2) * PI
                angles.append(angle)
            }
            angles.append(2 * PI)
            
            for i in 0 ..< numbers.count {
                let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: angles[i], endAngle: angles[i + 1], clockwise: true)
                let calyer = CAShapeLayer()
                calyer.path = path.cgPath
                calyer.strokeColor = UIColor.colorFromCode(colors[i]).cgColor
                calyer.strokeStart = 0
                calyer.strokeEnd = 0
                calyer.fillColor = UIColor.clear.cgColor
                calyer.lineWidth = arcWidth
                animation.beginTime = CACurrentMediaTime() + animation.duration * Double(i)
                animation.duration = 0.4 / Double(numbers.count)
                
                calyer.add(animation, forKey: "strokeEnd")
                self.layer.addSublayer(calyer)
            }
        } else {
            let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: 2 * PI, clockwise: true)
            let calyer = CAShapeLayer()
            calyer.path = path.cgPath
            calyer.strokeColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5).cgColor
            calyer.strokeStart = 0
            calyer.strokeEnd = 0
            calyer.fillColor = UIColor.clear.cgColor
            calyer.lineWidth = arcWidth
            animation.beginTime = CACurrentMediaTime()
            
            calyer.add(animation, forKey: "strokeEnd")
            self.layer.addSublayer(calyer)
        }
        
//        var outerPath = UIBezierPath(arcCenter: center, radius: radius + arcWidth / 2, startAngle: 0, endAngle: 2 * PI, clockwise: true)
//        outerPath.lineWidth = 2
//        UIColor.whiteColor().setStroke()
//        outerPath.stroke()
//        
//        var innerPath = UIBezierPath(arcCenter: center, radius: radius - arcWidth / 2, startAngle: 0, endAngle: 2 * PI, clockwise: true)
//        innerPath.lineWidth = 2
//        UIColor.whiteColor().setStroke()
//        innerPath.stroke()
        
        label = UILabel(frame: CGRect(x: center.x - 50, y: center.y - 20, width: 100, height: 40))
        label!.textAlignment = .center
        label!.adjustsFontSizeToFitWidth = true
        label!.font = UIFont.boldSystemFont(ofSize: 30)
        label!.textColor = UIColor.white
//        label!.backgroundColor = UIColor.redColor()
        addSubview(label!)
        if total == 0.0 {
            label!.text = "0.00"
        } else {
            let priceString = NSString(format: "%.2f", total)
            label!.text = priceString as String
        }
    }
}
