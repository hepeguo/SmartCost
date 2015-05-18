//
//  StatisticsViewController.swift
//  cost
//
//  Created by 郭振永 on 15/5/12.
//  Copyright (c) 2015年 guozy. All rights reserved.
//

import UIKit
import CoreData

class StatisticsViewController: UIViewController {
    
    var contentView: UIView?
    var counterView: CounterView?
    var graphView: GraphView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        view.layer.cornerRadius = 5
        view.backgroundColor = UIColor(red: 244 / 255, green: 111 / 255, blue: 102 / 255, alpha: 1)
        contentView = UIView(frame: view.frame)
        view.addSubview(contentView!)
        
        initTopBar()
        initStatisticsView()
    }
    
    override func viewWillAppear(animated: Bool) {
        contentView!.transform = CGAffineTransformMakeScale(0.9, 0.9)
        UIView.animateWithDuration(0.3, animations: {
            self.contentView!.transform = CGAffineTransformMakeScale(1, 1)
            }, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//MARK: init views
    
    func initTopBar() {
        let closeTap = UITapGestureRecognizer(target: self, action: "JustCloseStatisticsView:")
        
        var closeButton = UILabel(frame: CGRectMake(10, 27, 30, 30))
        closeButton.userInteractionEnabled = true
        closeButton.text = "✕"
        closeButton.textColor = UIColor.whiteColor()
        closeButton.font = UIFont(name: "Avenir-Heavy", size: 28)!
        closeButton.addGestureRecognizer(closeTap)
        contentView!.addSubview(closeButton)
    }
    
    func initStatisticsView() {
        let date = GDate()
        let day = date.getDay()
        var todayList = getMonthDataFromDatabase(day.year, month: day.month)
        
        let graphRect:CGRect = CGRectMake(0, 0, view.frame.width, 200)
        graphView = GraphView(frame: graphRect)
        graphView!.startColor = UIColor(red: 250 / 255, green: 233 / 255, blue: 222 / 255, alpha: 0.3)
        graphView!.endColor = UIColor(red: 252 / 255, green: 79 / 255, blue: 8 / 255, alpha: 0.3)
        graphView!.backgroundColor = UIColor.clearColor()
        
        let counterRect: CGRect = CGRectMake(view.frame.width / 2 - 100, 20, 200, 200)
        counterView = CounterView(frame: counterRect)
        counterView!.numbers = comboData(todayList!)
        counterView!.backgroundColor = UIColor.clearColor()
        
//        contentView?.addSubview(graphView!)
        contentView?.addSubview(counterView!)
    }
    
//MARK: action
    
    func JustCloseStatisticsView(sender: UITapGestureRecognizer) {
        UIView.animateWithDuration(0.3, animations: {
            self.contentView!.alpha = 0
            self.contentView!.transform = CGAffineTransformMakeScale(0.9, 0.9)
            }, completion: {_ in
                self.performSegueWithIdentifier("closeStatisticsView", sender: self)
        })
    }
    
//MARK: get data from database
    
    func getWeekDataFromDatabase(year: Int, weekOfYear: Int) -> [ItemModel]? {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName: "ItemModel")
        
        var error:NSError?
        
        fetchRequest.predicate = NSPredicate(format: "year == '\(year)' && weekOfYear == '\(weekOfYear)' && kill == false")
        let fetchResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as! [ItemModel]?
        return fetchResults
    }
    
    func getMonthDataFromDatabase(year: Int, month: Int) -> [ItemModel]? {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName: "ItemModel")
        
        var error:NSError?
        
        fetchRequest.predicate = NSPredicate(format: "year == '\(year)' && weekOfYear == '\(month)' && kill == false")
        let fetchResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as! [ItemModel]?
        return fetchResults
    }
    
    func getYearDataFromDatabase(year: Int) -> [ItemModel]? {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName: "ItemModel")
        
        var error:NSError?
        
        fetchRequest.predicate = NSPredicate(format: "year == '\(year)' && kill == false")
        let fetchResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as! [ItemModel]?
        return fetchResults
    }
    
    func comboData(data: [ItemModel]) -> [String: Float] {
        var sumKind: [String: Float] = [String: Float]()
        for itemModel in data {
            if sumKind[itemModel.kind] == nil {
                sumKind.updateValue(itemModel.price.floatValue, forKey: itemModel.kind)
            } else {
                sumKind[itemModel.kind]! += itemModel.price.floatValue
            }
        }
        println(sumKind)
        return sumKind
    }
    
    func getSum (data: [ItemModel]) -> (numberBeforeDot: Int, numberAfterDot: Int) {
        var sum: Float = 0.0
        var numberBeforeDot = 0
        var numberAfterDot = 0
        for itemModel in data {
            sum += itemModel.price.floatValue
        }
        numberBeforeDot = Int(sum)
        let totalString = "\(sum)" as NSString
        let location = [totalString .rangeOfString(".")].first?.location
        let stringAfterDot = totalString.substringFromIndex(location! + 1)
        numberAfterDot = stringAfterDot.toInt()!
        return (numberBeforeDot, numberAfterDot)
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
