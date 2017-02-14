//
//  CalendarWeekViewController.swift
//  calendar
//
//  Created by 郭振永 on 15/5/5.
//  Copyright (c) 2015年 guozy. All rights reserved.
//

import UIKit

protocol CalendarWeekViewControllerDelegate {
    func nextWeekView()
    func prevWeekView()
    func CalenderAfterAutoScroll()
    func selectedDay(_ date: GDate)
}

class CalendarWeekViewControllerView: UIView, UIScrollViewDelegate, CalendarWeekViewDelegate {
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
    // Drawing code
    }
    */
    var delegate:CalendarWeekViewControllerDelegate?
    var prevWeek: [GDate] = [GDate]()
    var presentWeek: [GDate] = [GDate]()
    var nextWeek: [GDate] = [GDate]()
    var scrollView: UIScrollView?
    
    var presentWeekView: CalendarWeekView?
    var prevWeekView: CalendarWeekView?
    var nextWeekView: CalendarWeekView?
    
    var prevWeekDay: GDate = GDate()
    var presentWeekDay: GDate = GDate()
    var nextWeekDay: GDate = GDate()
    
    var selectedDay: GDate = GDate()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let date = GDate()
        initContentView()
        getPresentWeek(date)
        initWeekView()
        presentWeekView?.selectDayFromWeek(selectedDay)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initContentView() {
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        scrollView!.contentSize = CGSize(width: frame.width * CGFloat(3), height: frame.height)
        scrollView!.setContentOffset(CGPoint(x: frame.width, y: 0), animated: false)
        
        scrollView!.isPagingEnabled = true
        scrollView!.showsHorizontalScrollIndicator = false
        scrollView!.showsVerticalScrollIndicator = false
        scrollView!.scrollsToTop = false
        scrollView!.isDirectionalLockEnabled = true
        scrollView!.delegate = self
        
        addSubview(scrollView!)
    }
    
    func getPresentWeek(_ date: GDate){
        var today = GDate()
        let todayOfWeek = today.getWeek().dayOfWeek
        presentWeekDay = today.addDay(-todayOfWeek + 1)
        prevWeekDay = presentWeekDay.addDay(-7)
        nextWeekDay = presentWeekDay.addDay(7)
        prevWeek = getDayOfWeek(prevWeekDay)
        presentWeek = getDayOfWeek(presentWeekDay)
        nextWeek = getDayOfWeek(nextWeekDay)
    }
    
    func initWeekView() {
        prevWeekView?.removeFromSuperview()
        prevWeekView = nil
        presentWeekView?.removeFromSuperview()
        presentWeekView = nil
        nextWeekView?.removeFromSuperview()
        nextWeekView = nil
        
        prevWeekView = CalendarWeekView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height), dayInWeek: prevWeek)
        presentWeekView = CalendarWeekView(frame: CGRect(x: frame.width, y: 0, width: frame.width, height: frame.height), dayInWeek: presentWeek)
        nextWeekView = CalendarWeekView(frame: CGRect(x: frame.width * 2, y: 0, width: frame.width, height: frame.height), dayInWeek: nextWeek)
        prevWeekView!.delegate = self
        presentWeekView!.delegate = self
        nextWeekView!.delegate = self
        scrollView!.addSubview(prevWeekView!)
        scrollView!.addSubview(presentWeekView!)
        scrollView!.addSubview(nextWeekView!)
    }
    
    func setCalendarSelectedDay(_ date: GDate) {
        var nextSelectDay = date;
        let nextDate = nextSelectDay.getDay()
        let nextWeekDayDate = nextWeekDay.getDay()
        let presentWeekDayDate = presentWeekDay.getDay()
        if GDate(year: nextDate.year, month: nextDate.month, day: nextDate.day, hour: 0, minute: 0, second: 0) >= GDate(year: nextWeekDayDate.year, month: nextWeekDayDate.month, day: nextWeekDayDate.day, hour: 0, minute: 0, second: 0) {
            scrollView!.setContentOffset(CGPoint(x: frame.width * 2, y: 0), animated: true)
            
            let todayOfWeek = nextSelectDay.getWeek().dayOfWeek
            presentWeekDay = nextSelectDay.addDay(-todayOfWeek + 1)
            prevWeekDay = presentWeekDay.addDay(-7)
            nextWeekDay = presentWeekDay.addDay(7)
            
            prevWeek = getDayOfWeek(prevWeekDay)
            presentWeek = getDayOfWeek(presentWeekDay)
            nextWeek = getDayOfWeek(nextWeekDay)
            
            selectedDay = nextSelectDay
        } else if GDate(year: nextDate.year, month: nextDate.month, day: nextDate.day, hour: 0, minute: 0, second: 0) < GDate(year: presentWeekDayDate.year, month: presentWeekDayDate.month, day: presentWeekDayDate.day, hour: 0, minute: 0, second: 0) {
            scrollView!.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            
            let todayOfWeek = nextSelectDay.getWeek().dayOfWeek
            presentWeekDay = nextSelectDay.addDay(-todayOfWeek + 1)
            prevWeekDay = presentWeekDay.addDay(-7)
            nextWeekDay = presentWeekDay.addDay(7)
            
            prevWeek = getDayOfWeek(prevWeekDay)
            presentWeek = getDayOfWeek(presentWeekDay)
            nextWeek = getDayOfWeek(nextWeekDay)
            
            selectedDay = nextSelectDay
        } else {
            selectedDay = nextSelectDay
            initWeekView()
            presentWeekView!.selectDayFromWeek(selectedDay)
        }
    }
    
    func setCurrentDay(_ date: GDate) {
        let currentDay = date.getDay()
        let headest = presentWeekDay.getDay()
        let lastDay = nextWeekDay.addDay(6)
        let lastest = lastDay.getDay()
        let C = GDate(year: currentDay.year, month: currentDay.month, day: currentDay.day, hour: 0, minute: 0, second: 0)
        let P = GDate(year: headest.year, month: headest.month, day: headest.day, hour: 0, minute: 0, second: 0)
        let L = GDate(year: lastest.year, month: lastest.month, day: lastest.day, hour: 0, minute: 0, second: 0)
        if (C > P && C < L) {
            initWeekView()
            setCalendarSelectedDay(selectedDay)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if(scrollView.contentOffset.x > frame.width) {
            prevWeekDay = presentWeekDay
            presentWeekDay = nextWeekDay
            nextWeekDay = presentWeekDay.addDay(7)
            
            prevWeek = presentWeek
            presentWeek = nextWeek
            nextWeek = getDayOfWeek(nextWeekDay)
            
            delegate?.nextWeekView()
        } else if (scrollView.contentOffset.x < frame.width) {
            nextWeekDay = presentWeekDay
            presentWeekDay = prevWeekDay
            prevWeekDay = presentWeekDay.addDay(-7)
            
            nextWeek = presentWeek
            presentWeek = prevWeek
            prevWeek = getDayOfWeek(prevWeekDay)
            
            delegate?.prevWeekView()
        }
        initWeekView()
        scrollView.setContentOffset(CGPoint(x: frame.width, y: 0), animated: false)
        setSelectDayInPresentWeek()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollView.setContentOffset(CGPoint(x: frame.width, y: 0), animated: false)
        initWeekView()
        presentWeekView!.selectDayFromWeek(selectedDay)
        delegate!.CalenderAfterAutoScroll()
    }
    
    func setSelectDayInPresentWeek() {
        let presentWeekEndDay = presentWeekDay.addDay(6)
        if selectedDay.between(presentWeekDay, presentWeekEndDay) {
            
        } else {
            presentWeekView!.selectFirstDayOfWeek()
            selectedDay = presentWeek[0]
        }
    }
    
    func scrollToPrevDay() {
        let nextSelectDay = selectedDay.addDay(-1)
        let nextDate = nextSelectDay.getDay()
        let presentWeekDayDate = presentWeekDay.getDay()
        if GDate(year: nextDate.year, month: nextDate.month, day: nextDate.day, hour: 0, minute: 0, second: 0) < GDate(year: presentWeekDayDate.year, month: presentWeekDayDate.month, day: presentWeekDayDate.day, hour: 0, minute: 0, second: 0) {
            nextWeekDay = presentWeekDay
            presentWeekDay = prevWeekDay
            prevWeekDay = presentWeekDay.addDay(-7)
            
            nextWeek = presentWeek
            presentWeek = prevWeek
            prevWeek = getDayOfWeek(prevWeekDay)
            
            delegate?.prevWeekView()
            scrollView!.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        } else {
            for (_, dayView) in presentWeekView!.dayViewOfWeek.enumerated() {
                if dayView.date == nextSelectDay {
                    dayView.isSelectedDay = true
                }
            }
        }
        selectedDay = nextSelectDay
    }
    
    func scrollToNextDay() {
        let nextSelectDay = selectedDay.addDay(1)
        let nextDate = nextSelectDay.getDay()
        let nextWeekDayDate = nextWeekDay.getDay()
        if GDate(year: nextDate.year, month: nextDate.month, day: nextDate.day, hour: 0, minute: 0, second: 0) >= GDate(year: nextWeekDayDate.year, month: nextWeekDayDate.month, day: nextWeekDayDate.day, hour: 0, minute: 0, second: 0) {
            prevWeekDay = presentWeekDay
            presentWeekDay = nextWeekDay
            nextWeekDay = presentWeekDay.addDay(7)
            
            prevWeek = presentWeek
            presentWeek = nextWeek
            nextWeek = getDayOfWeek(nextWeekDay)
            
            delegate?.nextWeekView()
            scrollView!.setContentOffset(CGPoint(x: frame.width * 2, y: 0), animated: true)
        } else {
            for (_, dayView) in presentWeekView!.dayViewOfWeek.enumerated() {
                if dayView.date == nextSelectDay {
                    dayView.isSelectedDay = true
                }
            }
        }
        selectedDay = nextSelectDay
    }
    
    func getDayOfWeek(_ weekDay: GDate) -> [GDate]{
        var weekDays = [GDate]()
        var day = weekDay
        for i in 0 ..< 7 {
            let date = day.addDay(i)
            weekDays.append(date)
        }
        return weekDays
    }
    
//MARK: CalendarWeekViewDelegate
    
    func selectedDay(_ dayView: CalendarDayView) {
        selectedDay = dayView.date!
        delegate?.selectedDay(selectedDay)
    }
    
    func unSelectedDay(_ dayView: CalendarDayView) {
        
    }
}
