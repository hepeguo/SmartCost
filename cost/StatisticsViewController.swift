//
//  StatisticsViewController.swift
//  cost
//
//  Created by 郭振永 on 15/5/12.
//  Copyright (c) 2015年 guozy. All rights reserved.
//

import UIKit
import CoreData

class StatisticsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var contentView: UIView?
    var counterView: CounterView?
    var graphView: GraphView?
    var tableView: UITableView?
    var kindAndSum: [Kind]? {
        didSet {
            tableView?.reloadData()
        }
    }
    
    var yearLabel: UILabel?
    var monthLabel: UILabel?
    var yearSelectView: UIScrollView?
    var monthSelectView: UIScrollView?
    var yearsView: [UILabel] = [UILabel]()
    var monthsView: [UILabel] = [UILabel]()
    var year: Int = 2015
    var month: Int = 0
    
    var colors = [0xe44B7D3, 0xeE42B6D, 0xeF4E24E, 0xeFE9616, 0xe8AED35,
        0xeff69b4, 0xeba55d3, 0xecd5c5c, 0xeffa500, 0xe40e0d0,
        0xeE95569, 0xeff6347, 0xe7b68ee, 0xe00fa9a, 0xeffd700,
        0xe6699FF, 0xeff6666, 0xe3cb371, 0xeb8860b, 0xe30e0e0, 0xee52c3c, 0xef7b1ab, 0xefa506c, 0xef59288, 0xef8c4d8,
        0xee54f5c, 0xef06d5c, 0xee54f80, 0xef29c9f, 0xeeeb5b7
    ]

    
    let theme = Theme()
    var theTheme: String {
        get {
            var returnValue: String? = NSUserDefaults.standardUserDefaults().objectForKey("theme") as? String
            if returnValue == nil
            {
                returnValue = "blue"
            }
            return returnValue!
        }
        set (newValue) {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "theme")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    var kinds: [CatagoriesModel] = [CatagoriesModel]()
    
    var moc: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        view.backgroundColor = theme.valueForKey(theTheme) as? UIColor
        contentView = UIView(frame: view.frame)
        view.addSubview(contentView!)
        let tap = UITapGestureRecognizer(target: self, action: "hideDateSelectView:")
        view.addGestureRecognizer(tap)
        
        if let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext {
            moc = context
        }
        getKinds()
        
        initTopBar()
        initStatisticsView()
        initTableView()
        initDateSelectView()
    }
    
    override func viewWillAppear(animated: Bool) {
        contentView!.transform = CGAffineTransformMakeScale(0.9, 0.9)
        UIView.animateWithDuration(0.3, animations: {
            self.contentView!.transform = CGAffineTransformMakeScale(1, 1)
            }, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
//MARK: init views
    
    func initTopBar() {
        let closeTap = UITapGestureRecognizer(target: self, action: "JustCloseStatisticsView:")
        
        let closeButton = UILabel(frame: CGRectMake(10, 27, 30, 30))
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
        year = day.year
        month = day.month
        
        
        /*折现图
        let graphRect:CGRect = CGRectMake(0, 0, view.frame.width, 200)
        graphView = GraphView(frame: graphRect)
        graphView!.startColor = UIColor(red: 250 / 255, green: 233 / 255, blue: 222 / 255, alpha: 0.3)
        graphView!.endColor = UIColor(red: 252 / 255, green: 79 / 255, blue: 8 / 255, alpha: 0.3)
        graphView!.backgroundColor = UIColor.clearColor()
        contentView?.addSubview(graphView!)
        */
        
        let counterRect: CGRect = CGRectMake(view.frame.width / 2 - 100, 20, 200, 200)
        counterView = CounterView(frame: counterRect)
        let dataList = getMonthDataFromDatabase(year, month: month)
        kindAndSum = comboData(dataList!)
        counterView!.numbers = kindAndSum!
        counterView!.backgroundColor = UIColor.clearColor()
        
        contentView?.addSubview(counterView!)
        
        yearLabel = UILabel(frame: CGRectMake(10, 180, 100, 20))
        yearLabel?.text = "Y: \(day.year)"
        yearLabel?.textColor = UIColor.whiteColor()
        yearLabel?.font = UIFont(name: "Avenir-Heavy", size: 18)!
        yearLabel?.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
        yearLabel?.layer.cornerRadius = 4
        yearLabel?.layer.masksToBounds = true
        yearLabel?.textAlignment = .Center
        yearLabel?.userInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: "showYearSelectView:")
        yearLabel?.addGestureRecognizer(tap)
        contentView?.addSubview(yearLabel!)
        
        monthLabel = UILabel(frame: CGRectMake(view.frame.width - 110, 180, 100, 20))
        monthLabel?.text = "M: \(day.month)"
        monthLabel?.layer.cornerRadius = 4
        monthLabel?.layer.masksToBounds = true
        monthLabel?.textAlignment = .Center
        monthLabel?.textColor = UIColor.whiteColor()
        monthLabel?.font = UIFont(name: "Avenir-Heavy", size: 18)!
        monthLabel?.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
        monthLabel?.userInteractionEnabled = true
        let tapMonth = UITapGestureRecognizer(target: self, action: "showMonthSelectView:")
        monthLabel?.addGestureRecognizer(tapMonth)
        contentView?.addSubview(monthLabel!)
    }
    
    func initTableView() {
        tableView = UITableView(frame: CGRectMake(0, 220, view.frame.width, view.frame.height - 220))
        tableView!.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView!.dataSource = self
        tableView!.delegate = self
        contentView!.addSubview(tableView!)
    }
    
    func initDateSelectView() {
        let date = GDate()
        let day = date.getDay()
        let startYear = 2010
        let length = 100
        yearSelectView = UIScrollView(frame: CGRectMake(10, 200, 0, 0))
        yearSelectView?.contentSize = CGSizeMake(50, 30 * CGFloat(length))
        yearSelectView?.setContentOffset(CGPointMake(0, 0), animated: false)
        yearSelectView?.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        yearSelectView?.layer.cornerRadius = 4
        yearSelectView?.alpha = 0
        
        yearSelectView?.showsHorizontalScrollIndicator = false
        yearSelectView?.showsVerticalScrollIndicator = false
        yearSelectView?.scrollsToTop = false
        yearSelectView?.directionalLockEnabled = true
        yearSelectView?.delegate = self
        
        for var i = startYear; i < startYear + length; i++ {
            let label = UILabel(frame: CGRectMake(0, CGFloat(i - startYear) * 30, 100, 30))
            label.text = "\(i)"
            label.textAlignment = .Center
            label.font = UIFont(name: "Avenir-Heavy", size: 18)!
            label.textColor = UIColor.whiteColor()
            label.userInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: "selectYear:")
            label.addGestureRecognizer(tap)
            
            if i == day.year {
                label.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
                yearSelectView?.setContentOffset(CGPointMake(0, CGFloat(i - startYear) * 30), animated: false)
            }
            yearsView.append(label)
            yearSelectView?.addSubview(label)
        }
        contentView?.addSubview(yearSelectView!)
        
        monthSelectView = UIScrollView(frame: CGRectMake(view.frame.width - 10, 200, 0, 0))
        monthSelectView?.contentSize = CGSizeMake(50, 30 * CGFloat(12))
        monthSelectView?.setContentOffset(CGPointMake(0, 0), animated: false)
        monthSelectView?.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        monthSelectView?.layer.cornerRadius = 4
        monthSelectView?.alpha = 0
        
        monthSelectView?.showsHorizontalScrollIndicator = false
        monthSelectView?.showsVerticalScrollIndicator = false
        monthSelectView?.scrollsToTop = false
        monthSelectView?.directionalLockEnabled = true
        monthSelectView?.delegate = self
        
        for var i = 1; i <= 12; i++ {
            let label = UILabel(frame: CGRectMake(0, CGFloat(i - 1) * 30, 100, 30))
            label.text = "\(i)"
            label.textAlignment = .Center
            label.font = UIFont(name: "Avenir-Heavy", size: 18)!
            label.textColor = UIColor.whiteColor()
            label.userInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: "selectMonth:")
            label.addGestureRecognizer(tap)
            if i == day.month {
                label.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
                monthSelectView?.setContentOffset(CGPointMake(0, CGFloat(i - 1) * 30), animated: false)
            }
            monthsView.append(label)
            monthSelectView?.addSubview(label)
        }
        contentView?.addSubview(monthSelectView!)
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
    
    func showYearSelectView(sender: UITapGestureRecognizer) {
        if yearSelectView?.alpha == 1 {
            UIView.animateWithDuration(0.3, animations: {
                self.yearSelectView?.alpha = 0
                self.yearSelectView?.frame.size = CGSizeMake(0, 0)
                }, completion: nil)
        } else {
            UIView.animateWithDuration(0.3, animations: {
                self.yearSelectView?.alpha = 1
                self.yearSelectView?.frame.size = CGSizeMake(100, 200)
            }, completion: nil)
        }
    }
    
    func showMonthSelectView(sender: UITapGestureRecognizer) {
        if monthSelectView?.alpha == 1 {
            UIView.animateWithDuration(0.3, animations: {
                self.monthSelectView?.alpha = 0
                self.monthSelectView?.frame = CGRectMake(self.view.frame.width - 10, 200, 0, 0)
            }, completion: nil)
        } else {
            UIView.animateWithDuration(0.3, animations: {
                self.monthSelectView?.alpha = 1
                self.monthSelectView?.frame = CGRectMake(self.view.frame.width - 110, 200, 100, 200)
            }, completion: nil)
        }
    }
    
    func selectYear(sender: UITapGestureRecognizer) {
        for (_, view) in yearsView.enumerate() {
            view.backgroundColor = UIColor.clearColor()
        }
        let label = sender.view as! UILabel
        label.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        UIView.animateWithDuration(0.3, animations: {
            self.yearSelectView?.alpha = 0
            self.yearSelectView?.frame.size = CGSizeMake(0, 0)
            }, completion: {_ in
                self.yearLabel?.text = "Y: " + label.text!
                self.year = Int(label.text!)!
                let dataList = self.getMonthDataFromDatabase(self.year, month: self.month)
                self.kindAndSum = self.comboData(dataList!)
                self.counterView!.numbers = self.kindAndSum!
        })
    }
    
    func selectMonth(sender: UITapGestureRecognizer) {
        for (_, view) in monthsView.enumerate() {
            view.backgroundColor = UIColor.clearColor()
        }
        let label = sender.view as! UILabel
        label.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        UIView.animateWithDuration(0.3, animations: {
            self.monthSelectView?.alpha = 0
            self.monthSelectView?.frame = CGRectMake(self.view.frame.width - 10, 200, 0, 0)
            }, completion: {_ in
                self.monthLabel?.text = "M: " + label.text!
                self.month = Int(label.text!)!
                let dataList = self.getMonthDataFromDatabase(self.year, month: self.month)
                self.kindAndSum = self.comboData(dataList!)
                self.counterView!.numbers = self.kindAndSum!
        })
    }
    
    func hideDateSelectView(sender: UITapGestureRecognizer) {
        UIView.animateWithDuration(0.3, animations: {
            self.monthSelectView?.alpha = 0
            self.monthSelectView?.frame = CGRectMake(self.view.frame.width - 10, 200, 0, 0)
            }, completion: nil)
        UIView.animateWithDuration(0.3, animations: {
            self.yearSelectView?.alpha = 0
            self.yearSelectView?.frame.size = CGSizeMake(0, 0)
            }, completion: nil)
    }
    
//MARK: get data from database
    
    func getWeekDataFromDatabase(year: Int, weekOfYear: Int) -> [ItemModel]? {
//        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName: "ItemModel")
        
        fetchRequest.predicate = NSPredicate(format: "year == '\(year)' && weekOfYear == '\(weekOfYear)' && kill == false")
        
        var fetchResults: [ItemModel]?
        do {
            try fetchResults = (moc.executeFetchRequest(fetchRequest) as! [ItemModel])
        } catch let error as NSError {
            print(error)
        }
        return fetchResults
    }
    
    func getMonthDataFromDatabase(year: Int, month: Int) -> [ItemModel]? {
//        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName: "ItemModel")
        
        fetchRequest.predicate = NSPredicate(format: "year == '\(year)' && month == '\(month)' && kill == false")
        
        var fetchResults: [ItemModel]?
        do {
            try fetchResults = (moc.executeFetchRequest(fetchRequest) as! [ItemModel])
        } catch let error as NSError {
            print(error)
        }
        
        return fetchResults
    }
    
    func getYearDataFromDatabase(year: Int) -> [ItemModel]? {
//        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName: "ItemModel")
        
        fetchRequest.predicate = NSPredicate(format: "year == '\(year)' && kill == false")
        
        var fetchResults: [ItemModel]?
        do {
            try fetchResults = (moc.executeFetchRequest(fetchRequest) as! [ItemModel])
        } catch let error as NSError {
            print(error)
        }
        return fetchResults
    }
    
    func comboData(data: [ItemModel]) -> [Kind] {
        var allKind: [Kind] = [Kind]()
        var hasKind: Bool = false
        for itemModel in data {
            if itemModel.kind.isEmpty {
                continue
            }
            for kind in allKind {
                if kind.name == itemModel.kind {
                    kind.sum += itemModel.price.floatValue
                    hasKind = true
                    break
                }
            }
            if !hasKind {
                let kind = Kind(name: itemModel.kind, price: itemModel.price.floatValue)
                allKind.append(kind)
            }
            hasKind = false
        }
        return allKind
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
        numberAfterDot = Int(stringAfterDot)!
        return (numberBeforeDot, numberAfterDot)
    }
    
    func getKinds() {
        let fetchRequest = NSFetchRequest(entityName: "Catagories")
        
        var fetchResults: [Catagories]?
        do {
            try fetchResults = (moc.executeFetchRequest(fetchRequest) as? [Catagories])
        } catch let error as NSError {
            print(error)
        }
        
        var kinds = [CatagoriesModel]()
        
        if fetchResults != nil && fetchResults?.count > 0 {
            for (_, item) in fetchResults!.enumerate() {
                let catagory: CatagoriesModel = CatagoriesModel()
                catagory.kind = item.kind!
                catagory.imageName = item.imageName!
                kinds.append(catagory)
            }
            self.kinds = kinds
        } else {
            let items = [
                ["kind": "Film","imageName": "Film"],
                ["kind": "Food","imageName": "Food"],
                ["kind": "Snacks","imageName": "Snacks"],
                ["kind": "Clothing","imageName": "Clothing"],
                ["kind": "Shopping","imageName": "Shopping"],
                ["kind": "Gifts","imageName": "Gifts"],
                ["kind": "Digital","imageName": "Digital"],
                ["kind": "Home","imageName": "Home"],
                ["kind": "Study","imageName": "Study"],
                ["kind": "Traffic","imageName": "Traffic"],
                ["kind": "Travel","imageName": "Travel"],
                ["kind": "Entertainment","imageName": "Entertainment"],
                ["kind": "Net Fee","imageName": "Net Fee"],
                ["kind": "Visa","imageName": "Visa"],
                ["kind": "Investment","imageName": "Investment"],
                ["kind": "Medicine","imageName": "Medicine"],
                ["kind": "Social","imageName": "Social"],
                ["kind": "Transfer","imageName": "Transfer"],
                ["kind": "Fine","imageName": "Fine"],
                ["kind": "Other","imageName": "Other"]
            ]
            
            for (_, item) in items.enumerate() {
                let kind: CatagoriesModel = CatagoriesModel()
                kind.kind = item["kind"]!
                kind.imageName = item["imageName"]!
                self.kinds.append(kind)
            }
        }
    }
    
    func getKingIamgeName(kind: String) -> String {
        var imageName = ""
        for (_, item) in kinds.enumerate() {
            if kind == item.kind {
                imageName = item.imageName
            }
        }
        
        return imageName
    }

//MARK: tableView delegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return kindAndSum!.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "cell")
        let kind: Kind = kindAndSum![indexPath.row];
        cell.textLabel?.text = kind.name
        
        let view = UIView(frame: CGRectMake(10, 10, 40, 40))
        view.backgroundColor = UIColor.colorFromCode(colors[indexPath.row])
        let imageView = UIImageView(frame: CGRectMake(5, 5, 30, 30))
        imageView.image = UIImage(named: getKingIamgeName(kind.name))
        view.addSubview(imageView)
        view.layer.cornerRadius = 10
        cell.addSubview(view)
        
        cell.imageView?.image = UIImage(named: "Film")
        let priceString = String(format: "%.2f", kind.sum)
        cell.detailTextLabel?.text = priceString as String
        cell.detailTextLabel?.textColor = UIColor.grayColor()
        cell.selectionStyle = .None
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        if (scrollView == tableView) {
            UIView.animateWithDuration(0.3, animations: {
                self.monthSelectView?.alpha = 0
                self.monthSelectView?.frame = CGRectMake(self.view.frame.width - 10, 200, 0, 0)
                }, completion: nil)
            UIView.animateWithDuration(0.3, animations: {
                self.yearSelectView?.alpha = 0
                self.yearSelectView?.frame.size = CGSizeMake(0, 0)
                }, completion: nil)
        }
        
    }
}
