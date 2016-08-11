//
//  CalendarDayView.swift
//  calendar
//
//  Created by 郭振永 on 15/4/27.
//  Copyright (c) 2015年 guozy. All rights reserved.
//

import UIKit
protocol CalendarDayViewDelegate {
    func selectedDay(dayView: CalendarDayView)
    func unSelectedDay(dayView: CalendarDayView)
}

class CalendarDayView: UIView {
    
    var delegate: CalendarDayViewDelegate?
    var dateLabel: UILabel?
    var date: GDate?
    var isSelectedDay: Bool = false {
        didSet {
            if isSelectedDay {
                setSelectedDay()
            } else {
                unSetSelectedDay()
            }
        }
    }
    var isPresentDay: Bool = false {
        didSet {
            if isPresentDay {
                setPresentDay()
            } else {
                unSetPresentDay()
            }
        }
    }
    var hasTips: Bool = false {
        didSet {
            if hasTips {
                setTips()
            }
        }
    }
    
    private var radius: CGFloat {
        get {
            return (min(frame.height, frame.width) - 10) / 2
        }
    }
    
    var selectedCircleView: GAuxiliaryView?
    
    var selectedDayFillColor: UIColor = UIColor.colorFromCode(0x1D62F0)
    var presentDayFillColor: UIColor = UIColor.redColor()
    
    var normalDayFontColor: UIColor = UIColor.blackColor()
    var presentDayFontColor: UIColor = UIColor.redColor()
    var selectedDayFontColor: UIColor = UIColor.whiteColor()
    
    var normalDayFont: UIFont = UIFont(name: "Avenir", size: 18)!
    var presentDayFont: UIFont = UIFont(name: "Avenir-Heavy", size: 18)!
    var selectedDayFont: UIFont = UIFont(name: "Avenir-Heavy", size: 18)!
    
    init(frame: CGRect, date: GDate) {
        super.init(frame: frame)
        self.date = date
        let rect = CGRectMake(0, 0, frame.width, frame.height)
        dateLabel = UILabel(frame: rect)
        dateLabel!.textAlignment = .Center
        dateLabel!.text = "\(date.getDay().day)"
        dateLabel!.font = normalDayFont
        dateLabel!.layer.zPosition = 2
        addSubview(dateLabel!)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(CalendarDayView.selectDay(_:)))
        tapGesture.numberOfTapsRequired = 1
        self.addGestureRecognizer(tapGesture)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func selectDay(sender: UITapGestureRecognizer) {
        if isSelectedDay {
            isSelectedDay = false
        } else {
            isSelectedDay = true
        }
    }
    
    func setPresentDay() {
        if isSelectedDay {
            if selectedCircleView == nil {
                let rect = CGRectMake(0, 0, frame.width, frame.height)
                selectedCircleView = GAuxiliaryView(rect: rect, shape: .Circle)
            }
            selectedCircleView!.fillColor = presentDayFillColor
            dateLabel!.textColor = selectedDayFontColor
            dateLabel!.font = selectedDayFont
            
            dateLabel!.transform = CGAffineTransformMakeScale(0.5, 0.5)
            selectedCircleView!.transform = CGAffineTransformMakeScale(0.5, 0.5)
            
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.1, options: UIViewAnimationOptions.BeginFromCurrentState, animations: {
                self.dateLabel!.transform = CGAffineTransformMakeScale(1, 1)
                self.selectedCircleView!.transform = CGAffineTransformMakeScale(1, 1)
                }, completion: nil)
        } else {
            dateLabel!.textColor = presentDayFontColor
            dateLabel!.font = presentDayFont
        }
    }
    
    func unSetPresentDay() {
        if isSelectedDay {
            selectedCircleView!.fillColor = selectedDayFillColor
            dateLabel!.textColor = selectedDayFontColor
            dateLabel!.font = selectedDayFont
        } else {
            dateLabel!.textColor = normalDayFontColor
            dateLabel!.font = normalDayFont
        }
    }
    
    func setSelectedDay() {
        if selectedCircleView == nil {
            let rect = CGRectMake(0, 0, frame.width, frame.height)
            selectedCircleView = GAuxiliaryView(rect: rect, shape: .Circle)
        }
        if isPresentDay {
            selectedCircleView!.fillColor = presentDayFillColor
        } else {
            selectedCircleView!.fillColor = selectedDayFillColor
        }
        addSubview(selectedCircleView!)
        dateLabel!.textColor = selectedDayFontColor
        dateLabel!.font = selectedDayFont
        
        dateLabel!.transform = CGAffineTransformMakeScale(0.5, 0.5)
        selectedCircleView!.transform = CGAffineTransformMakeScale(0.5, 0.5)
        
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.1, options: UIViewAnimationOptions.BeginFromCurrentState, animations: {
            self.dateLabel!.transform = CGAffineTransformMakeScale(1, 1)
            self.selectedCircleView!.transform = CGAffineTransformMakeScale(1, 1)
            }, completion: nil)
        delegate?.selectedDay(self)
    }
    
    func unSetSelectedDay() {
        if selectedCircleView != nil {
            UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                if let circleView = self.selectedCircleView {
                    circleView.transform = CGAffineTransformMakeScale(0.1, 0.1)
                    circleView.alpha = 0.1
                }
                }, completion: { _ in
                    self.selectedCircleView?.removeFromSuperview()
                    self.selectedCircleView = nil
            })
        }
        if isPresentDay {
            dateLabel!.textColor = presentDayFontColor
            dateLabel!.font = presentDayFont
        } else {
            dateLabel!.textColor = normalDayFontColor
            dateLabel!.font = normalDayFont
        }        
    }
    
    func setTips() {
        let rect = CGRectMake((frame.width - 5) / 2, frame.height - 5.0, 5.0, 5.0)
        let circleView = GAuxiliaryView(rect: rect, shape: .Circle)
        circleView.fillColor = UIColor.blueColor()
        addSubview(circleView)
    }
}
