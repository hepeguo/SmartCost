//
//  CounterNumber.swift
//  $Mate
//
//  Created by 郭振永 on 15/4/15.
//  Copyright (c) 2015年 guozy. All rights reserved.
//

import UIKit

class CounterNumber: UIView, UIScrollViewDelegate {
    var startNumber: Int = 0
    var startNumberAfterDot: Int = 0
    var font: UIFont = UIFont.systemFontOfSize(25.0)
    var fontColor: UIColor = UIColor.redColor()
    var fontSize: CGSize?
    
    var numberArray: [Character] = [Character]()
    var numberAfterDotArray: [Character] = [Character]()
    var numberScrollView: [UIView] = [UIView]()
    var afterDotNumberScrollView: [UIView] = [UIView]()
    
    var dotView: UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        getSizeOfFont()
        prepareNumberForEveryCharacter()
    }
    
    init(frame: CGRect, startNumber: Int, startNumberAfterDot: Int) {
        super.init(frame: frame)
        self.startNumber = startNumber
        self.startNumberAfterDot = startNumberAfterDot
        getSizeOfFont()
        prepareNumberForEveryCharacter()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getSizeOfFont() {
        let tempNumberString = "8"
        let tempNumberNSString = tempNumberString as NSString
        fontSize = tempNumberNSString.sizeWithAttributes([NSFontAttributeName: font])
    }
    
    func parseNumber(number: Int) -> [Character]{
        let numberString: String = "\(number)"
        var numberArray: [Character] = [Character]()
        for character in numberString.characters {
            numberArray.append(character)
        }
        return numberArray
    }
    
    func prepareNumberForEveryCharacter() {
        numberArray = parseNumber(startNumber)
        for (index, character) in numberArray.enumerate() {
            let scrollView = makeCharacterView(character)
            scrollView.frame = CGRectMake(fontSize!.width * CGFloat(index), 0, fontSize!.width, fontSize!.height)
            numberScrollView.append(scrollView)
            addSubview(scrollView)
        }
        
        dotView = UILabel(frame: CGRectMake(fontSize!.width * CGFloat(numberArray.count), 0, fontSize!.width, fontSize!.height))
        dotView!.textColor = fontColor
        dotView!.font = font
        dotView!.text = "."
        addSubview(dotView!)
        
        if startNumberAfterDot == 0 {
            numberAfterDotArray = ["0", "0"]
        } else if startNumberAfterDot < 10{
            numberAfterDotArray = parseNumber(startNumberAfterDot)
            numberAfterDotArray.append("0")
        } else {
            numberAfterDotArray = parseNumber(startNumberAfterDot)
        }
        for (index, character) in numberAfterDotArray.enumerate() {
            let scrollView = makeCharacterView(character)
            scrollView.frame = CGRectMake(fontSize!.width * CGFloat(index + numberArray.count + 1), 0, fontSize!.width, fontSize!.height)
            afterDotNumberScrollView.append(scrollView)
            addSubview(scrollView)
        }
    }
    
    func scrollToNumber(number: Int, numberAfterDot: Int) {
        var endNumberArray = parseNumber(number)
        let patchLength = endNumberArray.count - numberArray.count
        if  patchLength > 0 {
            for _ in 0 ..< patchLength {
                let scrollView = makeCharacterView("0")
                numberScrollView.insert(scrollView, atIndex: 0)
                addSubview(scrollView)
            }
        } else {
            for  _ in 0 ..< abs(patchLength) {
                let scrollView = numberScrollView.removeLast()
                scrollView.removeFromSuperview()
            }
        }
        
        for i in 0 ..< endNumberArray.count {
            let view: UIScrollView =  numberScrollView[i] as! UIScrollView
            view.frame = CGRectMake(fontSize!.width * CGFloat(i), 0, fontSize!.width, fontSize!.height)
            
            var numberString = ""
            numberString.append(endNumberArray[i])
            let numberValue: Int = Int(numberString)!
            view.setContentOffset(CGPointMake(0, fontSize!.height * CGFloat(numberValue)), animated: true)
        }
        numberArray = endNumberArray
        startNumber = number
        
        dotView!.frame = CGRectMake(fontSize!.width * CGFloat(endNumberArray.count), 0, fontSize!.width, fontSize!.height)
        
        var endNumberAfterDotArray = parseNumber(numberAfterDot)
        let afterDotPatchLength = endNumberAfterDotArray.count - numberAfterDotArray.count
        if  afterDotPatchLength > 0 {
            for _ in 0 ..< afterDotPatchLength {
                let scrollView = makeCharacterView("0")
                afterDotNumberScrollView.insert(scrollView, atIndex: 0)
                addSubview(scrollView)
            }
        } else if afterDotPatchLength < 0{
            //小数点后面的位数不一致的时候的处理，保证至少两位小数
            if endNumberAfterDotArray.count >= 2 {
                for _ in 0 ..< abs(afterDotPatchLength) {
                    let scrollView = afterDotNumberScrollView.removeLast()
                    scrollView.removeFromSuperview()
                }
            } else {
                for index in 0..<numberAfterDotArray.count {
                    if index >= 2 {
                        let scrollView = afterDotNumberScrollView.removeAtIndex(index)
                        scrollView.removeFromSuperview()
                    } else if index == 1 {
                        endNumberAfterDotArray.append("0")
                    }                   
                }
            }
            for _ in 0 ..< abs(afterDotPatchLength) {
                if endNumberAfterDotArray.count > 2 {
                    let scrollView = afterDotNumberScrollView.removeLast()
                    scrollView.removeFromSuperview()
                } else if endNumberAfterDotArray.count < 2{
                    endNumberAfterDotArray.append("0")
                } else {
                    break
                }
            }
        }
        
        for (index, character) in endNumberAfterDotArray.enumerate() {
            let scrollView: UIScrollView =  afterDotNumberScrollView[index] as! UIScrollView
            scrollView.frame = CGRectMake(fontSize!.width * CGFloat(index + endNumberArray.count + 1), 0, fontSize!.width, fontSize!.height)
            
            var numberString = ""
            numberString.append(character)
            let numberValue: Int = Int(numberString)!
            scrollView.setContentOffset(CGPointMake(0, fontSize!.height * CGFloat(numberValue)), animated: true)
        }
        numberAfterDotArray = endNumberAfterDotArray
        startNumberAfterDot = numberAfterDot
    }
    
    func makeCharacterView(number: Character) -> UIView {
        var numberString = ""
        numberString.append(number)
        let numberValue: Int = Int(numberString)!
        
        let rect: CGRect = CGRectMake(0, 0, fontSize!.width, fontSize!.height)
        let scrollView = UIScrollView(frame: rect)
        scrollView.contentSize = CGSizeMake(rect.width, rect.height * CGFloat(10))
        for i in 0 ..< 10 {
            let label: UILabel = UILabel()
            label.frame = CGRectMake(0, fontSize!.height * CGFloat(i), fontSize!.width, fontSize!.height)
            label.text = "\(i)"
            label.textColor = fontColor
            label.font = font
            scrollView.addSubview(label)
        }
        scrollView.setContentOffset(CGPointMake(0, rect.height * CGFloat(numberValue)), animated: false)
        
        scrollView.pagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.scrollsToTop = false
        scrollView.directionalLockEnabled = true
        scrollView.userInteractionEnabled = false
        scrollView.delegate = self
        
        return scrollView
    }
}
