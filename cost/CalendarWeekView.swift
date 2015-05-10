//
//  CalendarWeekView.swift
//  calendar
//
//  Created by 郭振永 on 15/5/4.
//  Copyright (c) 2015年 guozy. All rights reserved.
//

import UIKit

protocol CalendarWeekViewDelegate {
    func selectedDay(dayView: CalendarDayView)
    func unSelectedDay(dayView: CalendarDayView)
}

class CalendarWeekView: UIView, CalendarDayViewDelegate {
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
    // Drawing code
    }
    */
    var delegate:CalendarWeekViewDelegate?
    var dayOfWeek: [GDate]?
    var dayViewOfWeek: [CalendarDayView] = [CalendarDayView]()
    var firstDayOfWeek: Int = 0
    
    var padding: CGFloat = 0.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(frame: CGRect, dayInWeek: [GDate]) {
        super.init(frame: frame)
        self.dayOfWeek = dayInWeek
        
        initDayViewsInWeek()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initDayViewsInWeek() {
        let height = frame.height
        let width = (frame.width - padding * 6) / 7
        var rect = CGRectMake(0, 0, width, height)
        
        for (index, day) in enumerate(dayOfWeek!) {
            rect.origin.x =  CGFloat(index) * (width + padding)
            let dayView = CalendarDayView(frame: rect, date: day)
            if day == GDate() {
                dayView.isPresentDay = true
            }
            dayView.delegate = self
            dayViewOfWeek.append(dayView)
            addSubview(dayView)
        }
    }
    
    func selectedDay(dayView: CalendarDayView) {
        for view in dayViewOfWeek {
            if view.date != dayView.date {
                view.isSelectedDay = false
            }
        }
        delegate?.selectedDay(dayView)
    }
    
    func unSelectedDay(dayView: CalendarDayView) {
        
    }
    
    func selectFirstDayOfWeek() {
        dayViewOfWeek[0].isSelectedDay = true
    }
    
    func unSelectAllDayOfWeek() {
        for view in dayViewOfWeek {
            view.isSelectedDay = false
        }
    }
    
    func selectDayFromWeek(day: GDate) {
        for view in dayViewOfWeek {
            if view.date == day {
                view.isSelectedDay = true
            } else {
                view.isSelectedDay = false
            }
        }
    }
}


