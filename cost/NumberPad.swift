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
    func tappedOK()
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
        
        let blurEffect = UIBlurEffect(style: .Light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = CGRectMake(0, 0, frame.width, frame.height)
        self.addSubview(blurEffectView)
        
        initNumberView()
    }
    
    var string: String = ""
    var dotTapped: Bool = false
    var afterDotTappedTapNumber: Int = 0

    required init?(coder aDecoder: NSCoder) {
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
        for (index, name) in labelName.enumerate() {
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
        for (index, name) in controllerName.enumerate() {
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
        if string == "0" {
            string = ""
        }
        if let label = sender.view as? UILabel{
            if let text = label.text {
                if dotTapped {
                    if text == "." {
                        
                    } else if text == "⌫" {
                        afterDotTappedTapNumber--
                        let index = string.endIndex.advancedBy(-1);
                        string = string.substringToIndex(index)
                        if afterDotTappedTapNumber < 0 {
                            afterDotTappedTapNumber = 0
                            dotTapped = false
                        }
                    } else if text == "C" {
                        dotTapped = false
                        afterDotTappedTapNumber = 0
                        string = "0"
                    } else if text == "OK" {
                        delegate!.tappedOK()
                    }else {
                        afterDotTappedTapNumber++
                        if afterDotTappedTapNumber > 2 {
                            afterDotTappedTapNumber = 2
                            let index = string.endIndex.advancedBy(-1);
                            let newstring = string.substringToIndex(index)
                            string = newstring + text
                        } else {
                            string = string + text
                        }
                    }
                } else {
                    switch text {
                    case "0": string = string + text
                    case "1": string = string + text
                    case "2": string = string + text
                    case "3": string = string + text
                    case "4": string = string + text
                    case "5": string = string + text
                    case "6": string = string + text
                    case "7": string = string + text
                    case "8": string = string + text
                    case "9": string = string + text
                    case "C": string = "0"
                    case ".":
                        dotTapped = true
                        if string.isEmpty {
                            string = "0" + text
                        } else {
                            string = string + text
                        }
                    case "⌫":
                        if string == "0" || string == "" {
                            return
                        }
                        let index = string.endIndex.advancedBy(-1);
                        let newstring = string.substringToIndex(index)
                        if newstring.isEmpty {
                            string = "0"
                        } else {
                            string = newstring
                        }
                    case "OK":
                        delegate!.tappedOK()
                    default: return
                    }
                }
            }
        }
        if string == "" {
            string = "0"
        }
        let label = sender.view as? UILabel
        if label?.text != "OK" {
            delegate?.tappedNumber(string)
        }
    }
}


