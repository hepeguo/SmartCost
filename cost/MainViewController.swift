//
//  MainViewController.swift
//  $Mate
//
//  Created by 郭振永 on 15/4/7.
//  Copyright (c) 2015年 guozy. All rights reserved.
//

import UIKit
import CoreData

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ListPageScrollViewDelegate, CalendarWeekViewControllerDelegate {
    
    var listView: UIView?
    var pageScrollView: ListPageScrollView?
    
    var topBar:UIView?
    var calendarView: CalendarWeekViewControllerView?
    var counterNumber: CounterNumber?
    var dateLabel: UILabel?
    
    //三个列表的数据
    var todayList = [ItemModel]()
    var yesterdayList = [ItemModel]()
    var tomorrowList = [ItemModel]()
    //三个列表，昨天、今天、明天
    var todayTableView = UITableView()
    var yesterdayTableView = UITableView()
    var tomorrowTableView = UITableView()
    //年、月、日；用于查询三个列表的数据 weekOfYear用于查询一周数据
    var year: Int = 0
    var month: Int = 0
    var day: Int = 0
    var dayOfWeek: Int = 0
    var weekOfYear = 0
    //用户选择的日期偏离当前日期多少天
    var numberOfDayFromToday: Int = 0
    
    //默认的账本名，为多账本做准备
    var listName = "Mate"
    var monthName = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        view.layer.cornerRadius = 5
        view.backgroundColor = UIColor(red: 244 / 255, green: 111 / 255, blue: 102 / 255, alpha: 1)
        
        initYearMonthDay()
        
        initTableViews(CGRectMake(0, 130, view.bounds.width, view.bounds.height - 130))
        initDataForTableViews()
        initTopBar()
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "timeChanged:",
            name: UIApplicationSignificantTimeChangeNotification,
            object: nil)
    }
    
    func timeChanged(notification: NSNotification) {
        let date = GDate()
        let time = date.getTime()
        println("time changed \(time.hour): \(time.minute): \(time.second)")
        calendarView?.backgroundColor = UIColor.redColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.topBar!.frame.origin.y = -130
        self.listView?.frame.origin.y = self.view.frame.height
        UIView.animateWithDuration(0.3, animations: {
            self.topBar!.frame.origin.y = 0
            self.listView?.frame.origin.y = 130
            }, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK: - init views
    func initYearMonthDay() {
        let date = GDate()
        let yearMonthDay = date.getDay()
        let weekDayAndWeekOfYear = date.getWeek()
        
        year = yearMonthDay.year
        month = yearMonthDay.month
        day = yearMonthDay.day
        dayOfWeek = weekDayAndWeekOfYear.weekOfYear
        weekOfYear = weekDayAndWeekOfYear.dayOfWeek - 1
    }
    
    func initTopBar() {
        let fontBigger: UIFont = UIFont(name: "Avenir-Heavy", size: 30)!
        let fontBig: UIFont = UIFont(name: "Avenir-Heavy", size: 18)!
        let fontSmall: UIFont = UIFont(name: "Avenir-Heavy", size: 12)!
        let color: UIColor = UIColor.redColor()
        
        topBar = UIView(frame: CGRectMake(0, 0, view.bounds.width, 130))
        
        let statusLabel = UILabel(frame: CGRectMake(0, 0, view.frame.width, 20))
        statusLabel.backgroundColor = UIColor.whiteColor()
        
        dateLabel = UILabel(frame: CGRectMake(10, 20, 100, 22))
        let totalLabel = UILabel(frame: CGRectMake(10, 42, 70, 22))
        let addLabel = UILabel(frame: CGRectMake(view.bounds.width - 42, 25, 32, 32))
        addLabel.textAlignment = .Center
        addLabel.text = "+"
        addLabel.font = fontBigger
        
        dateLabel!.text = "\(monthName[month - 1]) \(year)"
        dateLabel!.font = fontSmall
        dateLabel!.textColor = color
        totalLabel.text = "TOTAL: "
        totalLabel.font = fontBig
        totalLabel.textColor = color
        
        counterNumber = CounterNumber(frame: CGRectMake(80, 36, 200, 22))
        let total = getSum(todayList)
        counterNumber!.startNumber = total.numberBeforeDot
        counterNumber!.startNumberAfterDot = total.numberAfterDot
        counterNumber!.backgroundColor = UIColor.clearColor()
        counterNumber!.fontColor = UIColor.redColor()
        
        let tap = UITapGestureRecognizer(target: self, action: "showAddItemView:")
        addLabel.userInteractionEnabled = true
        addLabel.addGestureRecognizer(tap)
        
        var calenderMenu = CalendarMenuView(frame: CGRectMake(0, 64, view.frame.width, 22))
        calendarView = CalendarWeekViewControllerView(frame: CGRectMake(0, 86, view.bounds.width, 44))
        calendarView!.backgroundColor = UIColor.whiteColor()
        calendarView!.layer.zPosition = 2
        calendarView!.delegate = self
        
        topBar!.addSubview(statusLabel)
        topBar!.addSubview(addLabel)
        topBar!.addSubview(dateLabel!)
        topBar!.addSubview(totalLabel)
        topBar!.addSubview(counterNumber!)
        topBar!.addSubview(calenderMenu)
        topBar!.addSubview(calendarView!)
        topBar?.backgroundColor = UIColor.whiteColor()
        view.addSubview(topBar!)
    }
    
    func initTableViews(frame: CGRect) {
        listView = UIView(frame: frame)
        view.addSubview(listView!)
        
        todayTableView.registerClass(TableViewCell.self, forCellReuseIdentifier: "cell")
        todayTableView.separatorStyle = .None
        todayTableView.backgroundColor = UIColor.clearColor()
        todayTableView.frame = CGRectMake(0, 0, frame.width, frame.height)
        todayTableView.dataSource = self
        todayTableView.delegate = self
        
        yesterdayTableView.registerClass(TableViewCell.self, forCellReuseIdentifier: "cell")
        yesterdayTableView.separatorStyle = .None
        yesterdayTableView.backgroundColor = UIColor.clearColor()
        yesterdayTableView.frame = CGRectMake(-view.bounds.width, 0, frame.width, frame.height)
        yesterdayTableView.dataSource = self
        yesterdayTableView.delegate = self
        
        tomorrowTableView.registerClass(TableViewCell.self, forCellReuseIdentifier: "cell")
        tomorrowTableView.separatorStyle = .None
        tomorrowTableView.backgroundColor = UIColor.clearColor()
        tomorrowTableView.frame = CGRectMake(view.bounds.width, 0, frame.width, frame.height)
        tomorrowTableView.dataSource = self
        tomorrowTableView.delegate = self
        
        let views = [yesterdayTableView, todayTableView, tomorrowTableView]
        
        let pageFrame = CGRectMake(0, 0, frame.width, frame.height)
        
        pageScrollView = ListPageScrollView(frame: pageFrame, views: views)
        pageScrollView!.delegate = self
        
        listView!.addSubview(pageScrollView!)
    }
    
    func initDataForTableViews() {
        var presentDate = GDate(year: year, month: month, day: day, hour: 0, minute: 0, second: 0)
        let todayFetchResults = getDayDataFromDatabase(year, month: month, day: day)
        let tomorrow = presentDate.addDay(1)
        let tomorrowDay = tomorrow.getDay()
        let tomorrowFetchResults = getDayDataFromDatabase(tomorrowDay.year, month: tomorrowDay.month, day: tomorrowDay.day)
        let yesterday = presentDate.addDay(-1)
        let yesterdayDay = yesterday.getDay()
        let yesterdayFetchResults = getDayDataFromDatabase(yesterdayDay.year, month: yesterdayDay.month, day: yesterdayDay.day)
        
        todayList = todayFetchResults!
        todayTableView.reloadData()
        
        tomorrowList = tomorrowFetchResults!
        tomorrowTableView.reloadData()
        
        yesterdayList = yesterdayFetchResults!
        yesterdayTableView.reloadData()
    }
    
    func initDataFromLeft() {
        var date = GDate(year: year, month: month, day: day, hour: 0, minute: 0, second: 0)
        let yesterdayFetchResults = getDayDataFromDatabase(year, month: month, day: day)
        
        yesterdayList = yesterdayFetchResults!
        yesterdayTableView.reloadData()
    }
    
    func initDataFromRight() {
        var date = GDate(year: year, month: month, day: day, hour: 0, minute: 0, second: 0)
        let tomorrowFetchResults = getDayDataFromDatabase(year, month: month, day: day)
        
        tomorrowList = tomorrowFetchResults!
        tomorrowTableView.reloadData()
    }
    
    /*
    func initStatisticsView() {
    let counterRect: CGRect = CGRectMake(0, 0, view.bounds.width, 200)
    counterView = CounterView(frame: counterRect)
    counterView!.numbers = comboData(todayList)
    counterView!.backgroundColor = UIColor.clearColor()
    
    let graphRect:CGRect = CGRectMake(0, 0, view.bounds.width, 200)
    graphView = GraphView(frame: graphRect)
    graphView!.startColor = UIColor(red: 250 / 255, green: 233 / 255, blue: 222 / 255, alpha: 1)
    graphView!.endColor = UIColor(red: 252 / 255, green: 79 / 255, blue: 8 / 255, alpha: 1)
    graphView!.backgroundColor = UIColor.clearColor()
    
    var views = [UIView]();
    views.append(counterView!)
    views.append(graphView!)
    
    var frame = CGRectMake(0, 0, view.bounds.width, 200)
    
    var page = PageView(frame: frame, views: views)
    statisticsView.addSubview(page)
    statisticsView.backgroundColor = UIColor(red: 244 / 255, green: 111 / 255, blue: 102 / 255, alpha: 0.9)
    }
    */
    
    //MARK: - action
    
    func showAddItemView(tap: UITapGestureRecognizer) {
        UIView.animateWithDuration(0.3, animations: {
            self.topBar!.frame.origin.y = -110
            self.listView?.frame.origin.y = self.view.frame.height
            }, completion: {_ in
                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("AddItemView") as! NewItemViewController
                self.presentViewController(vc, animated: false, completion: nil)
        })
    }
    
    func newItemFromAddView(item: Item) {
        if item.id != "" {
            saveItem(item)
        } else {
            addItem(item)
        }
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == yesterdayTableView {
            return yesterdayList.count
        } else if tableView == todayTableView {
            return todayList.count
        } else if tableView == tomorrowTableView {
            return tomorrowList.count
        } else {
            return todayList.count
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 110
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! TableViewCell
        var itemModel: ItemModel?
        if tableView == yesterdayTableView {
            itemModel = yesterdayList[indexPath.row]
        } else if tableView == todayTableView {
            itemModel = todayList[indexPath.row]
        } else if tableView == tomorrowTableView {
            itemModel = tomorrowList[indexPath.row]
        }
        var item = Item()
        if itemModel != nil {
            item.price = itemModel!.price as Float
            item.detail = itemModel!.detail
            item.kind = itemModel!.kind
            item.kill = itemModel!.kill as Bool
            item.year = itemModel!.year.toInt()!
            item.month = itemModel!.month.toInt()!
            item.day = itemModel!.day.toInt()!
            item.weekOfYear = itemModel!.weekOfYear.toInt()!
            item.time = itemModel!.addTime
            item.dayOfWeek = itemModel!.dayOfWeek.toInt()!
            cell.item = item
        }
        cell.backgroundColor = UIColor.clearColor()        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        UIView.animateWithDuration(0.3, animations: {
            self.topBar!.frame.origin.y = -110
            self.listView?.frame.origin.y = self.view.frame.height
            }, completion: {_ in
                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("AddItemView") as! NewItemViewController
                let item = self.todayList[indexPath.row]
                vc.item.price = item.price.floatValue
                vc.item.detail = item.detail
                vc.item.kind = item.kind
                vc.item.id = item.id
                self.presentViewController(vc, animated: false, completion: nil)
        })
    }
    
    //MARK: - get and save data
    
    func saveItem(item: Item) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        var error:NSError?
        var itemModel:ItemModel?
        let fetchRequest = NSFetchRequest(entityName: "ItemModel")
        fetchRequest.predicate = NSPredicate(format: "id == '\(item.id)'")
        
        let fetchResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as! [ItemModel]?

        if fetchResults != nil && fetchResults?.count > 0 {
            itemModel = fetchResults![0]
        }
        if itemModel != nil {
            let date = GDate()
            let time = date.getTime()
            itemModel!.price = item.price
            itemModel!.detail = item.detail
            itemModel!.kind = item.kind
            itemModel!.kill = item.kill
            itemModel!.addTime = "\(time.hour): \(time.minute): \(time.second)"
            
            if !managedContext.save(&error) {
                println("Could not save\(error), \(error?.userInfo)")
            }
            
            for (index, item)in enumerate(todayList) {
                if item.id == todayList[index].id {
                    todayList[index] = item
                    break
                }
            }
        }
        
        let total = getSum(todayList)
        counterNumber!.scrollToNumber(total.numberBeforeDot, numberAfterDot: total.numberAfterDot)
        todayTableView.reloadData()
    }
    
    func addItem(item: Item) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName: "BookModel")
        fetchRequest.predicate = NSPredicate(format: "name == '\(listName)'")
        
        var error:NSError?
        var book: BookModel?
        
        let fetchResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as! [BookModel]?
        
        if fetchResults != nil && fetchResults?.count > 0 {
            book = fetchResults![0]
        }
        
        if book == nil{
            book = NSEntityDescription.insertNewObjectForEntityForName("BookModel", inManagedObjectContext: managedContext) as? BookModel
            book!.name = "\(listName)"
        }
        
        var itemModel: ItemModel = NSEntityDescription.insertNewObjectForEntityForName("ItemModel", inManagedObjectContext: managedContext) as! ItemModel
        
        let date = GDate()
        let time = date.getTime()
        itemModel.id = "\(date.timeInterval)"
        itemModel.price = item.price
        itemModel.book = book!
        itemModel.detail = item.detail
        itemModel.kind = item.kind
        itemModel.kill = item.kill
        itemModel.addTime = "\(time.hour): \(time.minute): \(time.second)"
        itemModel.year = "\(year)"
        itemModel.month = "\(month)"
        itemModel.day = "\(day)"
        itemModel.weekOfYear = "\(weekOfYear)"
        itemModel.dayOfWeek = "\(dayOfWeek)"
        
        if !managedContext.save(&error) {
            println("Could not save\(error), \(error?.userInfo)")
        }
        
        todayList.append(itemModel)
        
        let total = getSum(todayList)
        counterNumber!.scrollToNumber(total.numberBeforeDot, numberAfterDot: total.numberAfterDot)
        todayTableView.reloadData()
    }
    
    func getDayDataFromDatabase(year: Int, month: Int, day: Int) -> [ItemModel]? {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName: "ItemModel")
        
        var error:NSError?
        
        fetchRequest.predicate = NSPredicate(format: "year == '\(year)' && month == '\(month)' && day == '\(day)'")
        let fetchResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as! [ItemModel]?
        return fetchResults
    }
    
    func getWeekDataFromDatabase(year: Int, weekOfYear: Int) -> [ItemModel]? {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName: "ItemModel")
        
        var error:NSError?
        
        fetchRequest.predicate = NSPredicate(format: "year == '\(year)' && weekOfYear == '\(weekOfYear)'")
        let fetchResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as! [ItemModel]?
        return fetchResults
    }
    
    func getMonthDataFromDatabase(year: Int, month: Int) -> [ItemModel]? {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName: "ItemModel")
        
        var error:NSError?
        
        fetchRequest.predicate = NSPredicate(format: "year == '\(year)' && weekOfYear == '\(month)'")
        let fetchResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as! [ItemModel]?
        return fetchResults
    }
    
    func getYearDataFromDatabase(year: Int) -> [ItemModel]? {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName: "ItemModel")
        
        var error:NSError?
        
        fetchRequest.predicate = NSPredicate(format: "year == '\(year)'")
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
    
//  MARK: - delegate for ListPageScrollView
    
    func next() {
        yesterdayList = todayList
        todayList = tomorrowList
        var date = GDate()
        let presentDate = date.addDay(++numberOfDayFromToday)
        let dateTemp = presentDate.getDay()
        let weekTemp = presentDate.getWeek()
        year = dateTemp.year
        month = dateTemp.month
        day = dateTemp.day
        weekOfYear = weekTemp.weekOfYear
        dayOfWeek = weekTemp.dayOfWeek
        
        var dateForGetData = date.addDay(numberOfDayFromToday + 1)
        let dateForGetDataTemp = dateForGetData.getDay()
        let yearTemp = dateForGetDataTemp.year
        let monthTemp = dateForGetDataTemp.month
        let dayTemp = dateForGetDataTemp.day
        
        calendarView?.scrollToNextDay()
        
        tomorrowList = getDayDataFromDatabase(yearTemp, month: monthTemp, day: dayTemp)!
        
        let total = getSum(todayList)
        counterNumber!.scrollToNumber(total.numberBeforeDot, numberAfterDot: total.numberAfterDot)
        
        todayTableView.reloadData()
        yesterdayTableView.reloadData()
        tomorrowTableView.reloadData()
    }
    
    func prev() {
        tomorrowList = todayList
        todayList = yesterdayList
        var date = GDate()
        let presentDate = date.addDay(--numberOfDayFromToday)
        let dateTemp = presentDate.getDay()
        let weekTemp = presentDate.getWeek()
        year = dateTemp.year
        month = dateTemp.month
        day = dateTemp.day
        weekOfYear = weekTemp.weekOfYear
        dayOfWeek = weekTemp.dayOfWeek
        
        let dateForGetData = date.addDay(numberOfDayFromToday - 1)
        let dateForGetDataTemp = dateForGetData.getDay()
        let yearTemp = dateForGetDataTemp.year
        let monthTemp = dateForGetDataTemp.month
        let dayTemp = dateForGetDataTemp.day
        
        calendarView?.scrollToPrevDay()
        
        yesterdayList = getDayDataFromDatabase(yearTemp, month: monthTemp, day: dayTemp)!
        
        let total = getSum(todayList)
        counterNumber!.scrollToNumber(total.numberBeforeDot, numberAfterDot: total.numberAfterDot)
        
        todayTableView.reloadData()
        yesterdayTableView.reloadData()
        tomorrowTableView.reloadData()
    }
    
    func afterAutoScroll() {
        initDataForTableViews()
    }
    
//  MARK: CalendarWeekViewControllerDelegate
    func selectedDay(date: GDate) {
        let selectedDay = date.getDay()
        let seletedDate = GDate(year: selectedDay.year, month: selectedDay.month, day: selectedDay.day, hour: 0, minute: 0, second: 0)
        let today = GDate(year: year, month: month, day: day, hour: 0, minute: 0, second: 0)
        
        let selectedWeek = seletedDate.getWeek()
        year = selectedDay.year
        month = selectedDay.month
        day = selectedDay.day
        weekOfYear = selectedWeek.weekOfYear
        dayOfWeek = selectedWeek.dayOfWeek
        
        if today > seletedDate {
            let length = (today.timeInterval - seletedDate.timeInterval) / 24 / 3600
            numberOfDayFromToday -= Int(length)
            initDataFromLeft()
            
            pageScrollView!.autoScrollLeft()
        } else if today < seletedDate {
            let length = (seletedDate.timeInterval - today.timeInterval) / 24 / 3600
            numberOfDayFromToday += Int(length)
            initDataFromRight()
            
            pageScrollView!.autoScrollRight()
        }
        if "\(monthName[month - 1]) \(year)" != dateLabel!.text {
            println("month changed")
            dateLabel!.text = "\(monthName[month - 1]) \(year)"
        }
        
        println("\(selectedDay.year), \(selectedDay.month), \(selectedDay.day) is selected!")
    }
    
    func nextWeekView() {
        
    }
    
    func prevWeekView() {
        
    }
    
    func CalenderAfterAutoScroll(){
        
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