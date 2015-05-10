//
//  NumberPad.swift
//  $Mate
//
//  Created by 郭振永 on 15/5/8.
//  Copyright (c) 2015年 guozy. All rights reserved.
//

import UIKit
protocol NumberPadDelegate {
    func tappedNumber(text: String)
}

class NumberPad: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    var padding: CGFloat = 0
    var font: UIFont = UIFont(name: "Avenir-Heavy", size: 18)!
    var fontColor: UIColor = UIColor.whiteColor()
    var delegate: NumberPadDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        initNumberView()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initNumberView() {
        let width: CGFloat = (frame.width - padding) / 4
        let height: CGFloat = frame.height / 4
        for var i = 1; i < 10; i++ {
            let label: UILabel = UILabel(frame: CGRectMake(width * CGFloat((i - 1) % 3), height * CGFloat(Int((i - 1) / 3)), width, height))
            label.text = "\(i)"
            label.font = font
            label.textColor = fontColor
            label.textAlignment = .Center
            label.userInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: "tappedNumber:")
            label.addGestureRecognizer(tap)
            addSubview(label)
        }
        let labelName = [".", "0", "⌫"]
        for (index, name) in enumerate(labelName) {
            let label: UILabel = UILabel(frame: CGRectMake(width * CGFloat(index), height * CGFloat(3), width, height))
            label.text = "\(name)"
            label.font = font
            label.textColor = fontColor
            label.textAlignment = .Center
            label.userInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: "tappedNumber:")
            label.addGestureRecognizer(tap)
            addSubview(label)
        }
        let controllerName = ["C", "OK"]
        for (index, name) in enumerate(controllerName) {
            let label: UILabel = UILabel(frame: CGRectMake(width * CGFloat(3), height * CGFloat(2 * index), width, height * CGFloat(2)))
            label.text = "\(name)"
            label.font = font
            label.textColor = fontColor
            label.textAlignment = .Center
            label.userInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: "tappedNumber:")
            label.addGestureRecognizer(tap)
            addSubview(label)
        }
    }
    
    func tappedNumber(sender: UITapGestureRecognizer) {
        if let label = sender.view as? UILabel{
            if let text = label.text {
                delegate?.tappedNumber(text)
            }
        }
    }
}


