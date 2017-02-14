//
//  MainViewController.swift
//  $Mate
//
//  Created by 郭振永 on 15/4/7.
//  Copyright (c) 2015年 guozy. All rights reserved.
//

import UIKit
import CoreData
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ListPageScrollViewDelegate, CalendarWeekViewControllerDelegate {
    
    var listView: UIView?
    var pageScrollView: ListPageScrollView?
    
    var topBar:UIView?
    var calendarView: CalendarWeekViewControllerView?
    var counterNumber: CounterNumber?
    var dateLabel: UILabel?
    var gotoTodayIcon: UIImageView?
    
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
    
    var moc: NSManagedObjectContext!
    
    let theme = Theme()
    var theTheme: String {
        get {
            var returnValue: String? = UserDefaults.standard.object(forKey: "theme") as? String
            if returnValue == nil
            {
                returnValue = "blue"
            }
            return returnValue!
        }
        set (newValue) {
            UserDefaults.standard.set(newValue, forKey: "theme")
            UserDefaults.standard.synchronize()
        }
    }
    var kinds: [CatagoriesModel] = [CatagoriesModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        view.backgroundColor = theme.value(forKey: theTheme) as? UIColor
        
        if let context = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext {
            moc = context
        }
        
        initYearMonthDay()
        initTableViews(CGRect(x: 0, y: 130, width: view.bounds.width, height: view.bounds.height - 130))
        initDataForTableViews()
        initTopBar()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(MainViewController.timeChanged(_:)),
            name: NSNotification.Name.UIApplicationSignificantTimeChange,
            object: nil)
    }
    
    func timeChanged(_ notification: Notification) {
        let date = GDate()
        calendarView?.setCurrentDay(date)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = theme.value(forKey: theTheme) as? UIColor
        self.topBar!.frame.origin.y = -130
        self.listView?.frame.origin.y = self.view.frame.height
        getKinds()
        todayTableView.reloadData()
        
        UIView.animate(withDuration: 0.3, animations: {
            self.topBar!.frame.origin.y = 0
            self.listView?.frame.origin.y = 130
            }, completion: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.persistentStoreDidChange), name: NSNotification.Name.NSPersistentStoreCoordinatorStoresDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.persistentStoreWillChange(_:)), name: NSNotification.Name.NSPersistentStoreCoordinatorStoresWillChange, object: moc.persistentStoreCoordinator)
        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.receiveICloudChanges(_:)), name: NSNotification.Name.NSPersistentStoreDidImportUbiquitousContentChanges, object: moc.persistentStoreCoordinator)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NSPersistentStoreCoordinatorStoresDidChange, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NSPersistentStoreCoordinatorStoresWillChange, object: moc.persistentStoreCoordinator)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NSPersistentStoreDidImportUbiquitousContentChanges, object: moc.persistentStoreCoordinator)
    }
    
    func persistentStoreDidChange() {
        initDataForTableViews()
        let total = getSum(todayList)
        counterNumber!.scrollToNumber(total.numberBeforeDot, numberAfterDot: total.numberAfterDot)
    }
    
    func persistentStoreWillChange(_ notifaction: Notification) {
        moc.perform({ () -> Void in
            if self.moc.hasChanges {
                let error: NSError? = nil
                
                do {
                    try self.moc.save()
                } catch let error as NSError {
                    print(error)
                }
                if error != nil {
                    print("save error: \(error)")
                } else {
                    self.moc.reset()
                }
            }
        })
    }
    
    func receiveICloudChanges(_ notifaction: Notification) {
        moc.perform { () -> Void in
            self.moc.mergeChanges(fromContextDidSave: notifaction)
            self.initDataForTableViews()
            let total = self.getSum(self.todayList)
            self.counterNumber!.scrollToNumber(total.numberBeforeDot, numberAfterDot: total.numberAfterDot)
        }
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
        let color: UIColor = UIColor.red
        
        topBar = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 130))
        
        let statusLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 20))
        statusLabel.backgroundColor = UIColor.white
        
        dateLabel = UILabel(frame: CGRect(x: 10, y: 20, width: 100, height: 22))
        dateLabel!.text = "\(monthName[month - 1]) \(year)"
        dateLabel!.font = fontSmall
        dateLabel!.textColor = color
        
        
        let setUpView = UIView(frame: CGRect(x: view.frame.width - 98, y: 20, width: 44, height: 44))
        setUpView.isUserInteractionEnabled = true
        let setUpTap = UITapGestureRecognizer(target: self, action: #selector(MainViewController.showSetUpView(_:)))
        setUpView.addGestureRecognizer(setUpTap)
        let setUpIcon = UIImageView(frame: CGRect(x: 13, y: 13, width: 18, height: 18))
        setUpIcon.image = UIImage(named: "setUp")
        setUpView.addSubview(setUpIcon)
        
        let addLabel = UILabel(frame: CGRect(x: view.bounds.width - 54, y: 20, width: 44, height: 44))
        addLabel.textAlignment = .center
        addLabel.text = "+"
        addLabel.font = fontBigger
        
        let totalLabel = UILabel(frame: CGRect(x: 10, y: 42, width: 70, height: 22))
        totalLabel.text = "TOTAL: "
        totalLabel.font = fontBig
        totalLabel.textColor = color
        
        let total = getSum(todayList)
        counterNumber = CounterNumber(frame: CGRect(x: 80, y: 36, width: view.frame.width - 178, height: 22), startNumber: total.numberBeforeDot, startNumberAfterDot: total.numberAfterDot)
        counterNumber!.fontColor = UIColor.red
        counterNumber!.backgroundColor = UIColor.clear
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(MainViewController.showAddItemView(_:)))
        addLabel.isUserInteractionEnabled = true
        addLabel.addGestureRecognizer(tap)
        
        let calenderMenu = CalendarMenuView(frame: CGRect(x: 0, y: 64, width: view.frame.width, height: 22))
        calendarView = CalendarWeekViewControllerView(frame: CGRect(x: 0, y: 86, width: view.bounds.width, height: 44))
        calendarView!.backgroundColor = UIColor.white
        calendarView!.layer.zPosition = 2
        calendarView!.delegate = self
        
        topBar!.addSubview(statusLabel)
        topBar!.addSubview(setUpView)
        topBar!.addSubview(addLabel)
        topBar!.addSubview(dateLabel!)
        topBar!.addSubview(totalLabel)
        topBar!.addSubview(counterNumber!)
        topBar!.addSubview(calenderMenu)
        topBar!.addSubview(calendarView!)
        topBar?.backgroundColor = UIColor.white
        view.addSubview(topBar!)
    }
    
    func initTableViews(_ frame: CGRect) {
        listView = UIView(frame: frame)
        view.addSubview(listView!)
        
        todayTableView.register(TableViewCell.self, forCellReuseIdentifier: "cell")
        todayTableView.separatorStyle = .none
        todayTableView.backgroundColor = UIColor.clear
        todayTableView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        todayTableView.dataSource = self
        todayTableView.delegate = self
        
        yesterdayTableView.register(TableViewCell.self, forCellReuseIdentifier: "cell")
        yesterdayTableView.separatorStyle = .none
        yesterdayTableView.backgroundColor = UIColor.clear
        yesterdayTableView.frame = CGRect(x: -view.bounds.width, y: 0, width: frame.width, height: frame.height)
        yesterdayTableView.dataSource = self
        yesterdayTableView.delegate = self
        
        tomorrowTableView.register(TableViewCell.self, forCellReuseIdentifier: "cell")
        tomorrowTableView.separatorStyle = .none
        tomorrowTableView.backgroundColor = UIColor.clear
        tomorrowTableView.frame = CGRect(x: view.bounds.width, y: 0, width: frame.width, height: frame.height)
        tomorrowTableView.dataSource = self
        tomorrowTableView.delegate = self
        
        let views = [yesterdayTableView, todayTableView, tomorrowTableView]
        
        let pageFrame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        
        pageScrollView = ListPageScrollView(frame: pageFrame, views: views)
        pageScrollView!.delegate = self
        
        listView!.addSubview(pageScrollView!)
        
        let statisticsIconView = UIView(frame: CGRect(x: frame.width - 48, y: frame.height - 66, width: 36, height: 36))
        statisticsIconView.isUserInteractionEnabled = true
        let showStatisticsViewTap = UITapGestureRecognizer(target: self, action: #selector(MainViewController.showStatisticsView(_:)))
        statisticsIconView.addGestureRecognizer(showStatisticsViewTap)
        
        let statistics = UIImageView(frame: CGRect(x: 8, y: 8, width: 18, height: 18))
        statistics.image = UIImage(named: "pan")
        
        statisticsIconView.addSubview(statistics)
        listView?.addSubview(statisticsIconView)
        
        let gotoTodayIconView = UIView(frame: CGRect(x: 10, y: frame.height - 66, width: 36, height: 36))
        gotoTodayIconView.isUserInteractionEnabled = true
        let gotoTodayTap = UITapGestureRecognizer(target: self, action: #selector(MainViewController.gotoToday(_:)))
        gotoTodayIconView.addGestureRecognizer(gotoTodayTap)
        
        gotoTodayIcon = UIImageView(frame: CGRect(x: 7, y: 7, width: 22, height: 22))
        gotoTodayIconView.addSubview(gotoTodayIcon!)
        listView?.addSubview(gotoTodayIconView)
    }
    
    func setupGotoTodayIcon() {
        if numberOfDayFromToday == 0 {
            UIView.animate(withDuration: 0.3, animations: {
                self.gotoTodayIcon?.alpha = 0
                }, completion: { _ in
                    self.gotoTodayIcon?.image = nil
            })
        } else if numberOfDayFromToday > 0 {
            gotoTodayIcon?.image = UIImage(named: "arrow-left")
            UIView.animate(withDuration: 0.3, animations: {
                self.gotoTodayIcon?.alpha = 1
                }, completion: nil)
        } else {
            gotoTodayIcon?.image = UIImage(named: "arrow-right")
            UIView.animate(withDuration: 0.3, animations: {
                self.gotoTodayIcon?.alpha = 1
                }, completion: nil)
        }
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
//        _ = GDate(year: year, month: month, day: day, hour: 0, minute: 0, second: 0)
        let yesterdayFetchResults = getDayDataFromDatabase(year, month: month, day: day)
        
        yesterdayList = yesterdayFetchResults!
        yesterdayTableView.reloadData()
    }
    
    func initDataFromRight() {
//        var date = GDate(year: year, month: month, day: day, hour: 0, minute: 0, second: 0)
        let tomorrowFetchResults = getDayDataFromDatabase(year, month: month, day: day)
        
        tomorrowList = tomorrowFetchResults!
        tomorrowTableView.reloadData()
    }
    
    //MARK: - action
    
    func showAddItemView(_ tap: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.3, animations: {
            self.topBar!.frame.origin.y = -110
            self.listView?.frame.origin.y = self.view.frame.height
            }, completion: {_ in
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddItemView") as! NewItemViewController
                self.present(vc, animated: false, completion: nil)
        })
    }
    
    func showSetUpView(_ tap: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.3, animations: {
            self.topBar!.frame.origin.y = -110
            self.listView?.frame.origin.y = self.view.frame.height
            }, completion: {_ in
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "setUpView") as! SetUpViewController
                self.present(vc, animated: false, completion: nil)
        })
    }
    
    func showStatisticsView(_ tap: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.3, animations: {
            self.topBar!.frame.origin.y = -110
            self.listView?.frame.origin.y = self.view.frame.height
            }, completion: {_ in
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "statisticsView") as! StatisticsViewController
                self.present(vc, animated: false, completion: nil)
        })
    }
    
    func newItemFromAddView(_ item: Item) {
        if item.id != "" {
            if item.kill {
                deleteItem(item)
            } else {
                saveItem(item)
            }
        } else {
            addItem(item)
        }
    }
    
    @IBAction func closeNewItemView(_ sender: UIStoryboardSegue) {
        //        println("success")
    }
    
    @IBAction func closeSetUpView(_ sender: UIStoryboardSegue) {
        //        println("success")
    }
    
    @IBAction func closeStatisticsView(_ sender: UIStoryboardSegue) {
        //        println("success")
    }
    
    func gotoToday(_ sender: UITapGestureRecognizer) {
        let date = GDate()
        calendarView?.setCalendarSelectedDay(date)
    }
 
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        var itemModel: ItemModel?
        if tableView == yesterdayTableView {
            itemModel = yesterdayList[indexPath.row]
        } else if tableView == todayTableView {
            itemModel = todayList[indexPath.row]
        } else if tableView == tomorrowTableView {
            itemModel = tomorrowList[indexPath.row]
        }
        let item = Item()
        if itemModel != nil {
            item.price = itemModel!.price as Float
            item.detail = itemModel!.detail
            item.kind = itemModel!.kind
            item.kill = itemModel!.kill as Bool
            item.year = Int(itemModel!.year)!
            item.month = Int(itemModel!.month)!
            item.day = Int(itemModel!.day)!
            item.weekOfYear = Int(itemModel!.weekOfYear)!
            item.time = itemModel!.addTime
            item.dayOfWeek = Int(itemModel!.dayOfWeek)!
            item.imageName = getKingIamgeName(item.kind)
            cell.item = item
        }
        cell.backgroundColor = UIColor.clear        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.3, animations: {
            self.topBar!.frame.origin.y = -110
            self.listView?.frame.origin.y = self.view.frame.height
            }, completion: {_ in
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddItemView") as! NewItemViewController
                let item = self.todayList[indexPath.row]
                vc.item.price = item.price.floatValue
                vc.item.detail = item.detail
                vc.item.kind = item.kind
                vc.item.id = item.id
                self.present(vc, animated: false, completion: nil)
        })
    }
    
    //MARK: - get and save data
    func deleteItem(_ item: Item) {
        var itemModel:ItemModel?
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ItemModel")
        fetchRequest.predicate = NSPredicate(format: "id == '\(item.id)'")
        
        var fetchResults: [ItemModel]?
        do {
            try fetchResults = (moc.fetch(fetchRequest) as! [ItemModel])
        } catch let error as NSError {
            print(error)
        }
        
        if fetchResults != nil && fetchResults?.count > 0 {
            itemModel = fetchResults![0]
        }
        if itemModel != nil {
            itemModel!.kill = item.kill as NSNumber
            
            do {
                try moc.save()
            } catch let error as NSError {
                print(error)
            }
            
            for (index, data) in todayList.enumerated() {
                if item.id == data.id {
                    todayList.remove(at: index)
                    break
                }
            }
        }
        
        let total = getSum(todayList)
        counterNumber!.scrollToNumber(total.numberBeforeDot, numberAfterDot: total.numberAfterDot)
        todayTableView.reloadData()
    }
    
    func saveItem(_ item: Item) {
        var itemModel:ItemModel?
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ItemModel")
        fetchRequest.predicate = NSPredicate(format: "id == '\(item.id)'")
        
        var fetchResults: [ItemModel]?
        do {
            try fetchResults = (moc.fetch(fetchRequest) as! [ItemModel])
        } catch let error as NSError {
            print(error)
        }

        if fetchResults != nil && fetchResults?.count > 0 {
            itemModel = fetchResults![0]
        }
        if itemModel != nil {
            let date = GDate()
            let time = date.getTime()
            itemModel!.price = NSNumber(value: item.price)
            itemModel!.detail = item.detail
            itemModel!.kind = item.kind
            itemModel!.isSpend = item.isSpend as NSNumber
            itemModel!.kill = item.kill as NSNumber
            itemModel!.addTime = "\(time.hour): \(time.minute): \(time.second)"
            
            do {
                try moc.save()
            } catch let error as NSError {
                print(error)
            }
            
            for (index, item)in todayList.enumerated() {
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
    
    func addItem(_ item: Item) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BookModel")
        fetchRequest.predicate = NSPredicate(format: "name == '\(listName)'")
        
        var book: BookModel?
        
        var fetchResults: [BookModel]?
        do {
            try fetchResults = (moc.fetch(fetchRequest) as! [BookModel])
        } catch let error as NSError {
            print(error)
        }
        
        if fetchResults != nil && fetchResults?.count > 0 {
            book = fetchResults![0]
        }
        
        if book == nil{
            book = NSEntityDescription.insertNewObject(forEntityName: "BookModel", into: moc) as? BookModel
            book!.name = "\(listName)"
        }
        
        let itemModel: ItemModel = NSEntityDescription.insertNewObject(forEntityName: "ItemModel", into: moc) as! ItemModel
        
        let date = GDate()
        let time = date.getTime()
        itemModel.id = "\(date.timeInterval)"
        itemModel.price = NSNumber(value: Double(item.price))
        itemModel.book = book!
        itemModel.isSpend = item.isSpend as NSNumber
        itemModel.detail = item.detail
        itemModel.kind = item.kind
        itemModel.kill = item.kill as NSNumber
        itemModel.addTime = "\(time.hour): \(time.minute): \(time.second)"
        itemModel.year = "\(year)"
        itemModel.month = "\(month)"
        itemModel.day = "\(day)"
        itemModel.weekOfYear = "\(weekOfYear)"
        itemModel.dayOfWeek = "\(dayOfWeek)"
        
        do {
            try moc.save()
        } catch let error as NSError {
            print(error)
        }
        
        todayList.append(itemModel)
        
        let total = getSum(todayList)
        counterNumber!.scrollToNumber(total.numberBeforeDot, numberAfterDot: total.numberAfterDot)
        todayTableView.reloadData()
    }
    
    func getDayDataFromDatabase(_ year: Int, month: Int, day: Int) -> [ItemModel]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ItemModel")
        
        fetchRequest.predicate = NSPredicate(format: "year == '\(year)' && month == '\(month)' && day == '\(day)' && kill == false")
        
        var fetchResults: [ItemModel]?
        do {
            try fetchResults = (moc.fetch(fetchRequest) as! [ItemModel])
        } catch let error as NSError {
            print(error)
        }
        return fetchResults
    }
    
    func getSum (_ data: [ItemModel]) -> (numberBeforeDot: Int, numberAfterDot: Int) {
        var sum: Double = 0.0
        var numberBeforeDot = 0
        var numberAfterDot = 0
        for itemModel in data {
            sum += itemModel.price.doubleValue
        }
        numberBeforeDot = Int(sum)
        let totalString = NSString(format: "%.2f", sum)
        let location = [totalString .range(of: ".")].first?.location
        let stringAfterDot = totalString.substring(from: location! + 1)
        if stringAfterDot == "0" {
            numberAfterDot = 0
        } else {
            numberAfterDot = Int(stringAfterDot)!
        }
        return (numberBeforeDot, numberAfterDot)
    }
    
    func getKinds() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Catagories")
        
        var fetchResults: [Catagories]?
        do {
            try fetchResults = (moc.fetch(fetchRequest) as? [Catagories])
        } catch let error as NSError {
            print(error)
        }
        
        var kinds = [CatagoriesModel]()
        
        if fetchResults != nil && fetchResults?.count > 0 {
            for (_, item) in fetchResults!.enumerated() {
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
            
            for (_, item) in items.enumerated() {
                let kind: CatagoriesModel = CatagoriesModel()
                kind.kind = item["kind"]!
                kind.imageName = item["imageName"]!
                self.kinds.append(kind)
//                saveKind(item["kind"]!, oldKind: item["kind"]!, imageName: item["imageName"]!)
            }
        }
    }
    
    func getKingIamgeName(_ kind: String) -> String {
        var imageName = ""
        for (_, item) in kinds.enumerated() {
            if kind == item.kind {
                imageName = item.imageName
            }
        }
        
        return imageName
     }
    
//  MARK: - delegate for ListPageScrollView
    
    func next() {
        yesterdayList = todayList
        todayList = tomorrowList
        var date = GDate()
        numberOfDayFromToday += 1
        let presentDate = date.addDay(numberOfDayFromToday)
        let dateTemp = presentDate.getDay()
        let weekTemp = presentDate.getWeek()
        year = dateTemp.year
        month = dateTemp.month
        day = dateTemp.day
        weekOfYear = weekTemp.weekOfYear
        dayOfWeek = weekTemp.dayOfWeek
        
        let dateForGetData = date.addDay(numberOfDayFromToday + 1)
        let dateForGetDataTemp = dateForGetData.getDay()
        let yearTemp = dateForGetDataTemp.year
        let monthTemp = dateForGetDataTemp.month
        let dayTemp = dateForGetDataTemp.day
        
        calendarView?.scrollToNextDay()
        
        tomorrowList = getDayDataFromDatabase(yearTemp, month: monthTemp, day: dayTemp)!
        
        let total = getSum(todayList)
        counterNumber!.scrollToNumber(total.numberBeforeDot, numberAfterDot: total.numberAfterDot)
        
        setupGotoTodayIcon()
        todayTableView.reloadData()
        yesterdayTableView.reloadData()
        tomorrowTableView.reloadData()
    }
    
    func prev() {
        tomorrowList = todayList
        todayList = yesterdayList
        var date = GDate()
        numberOfDayFromToday -= 1
        let presentDate = date.addDay(numberOfDayFromToday)
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
        
        setupGotoTodayIcon()
        todayTableView.reloadData()
        yesterdayTableView.reloadData()
        tomorrowTableView.reloadData()
    }
    
    func afterAutoScroll() {
        initDataForTableViews()
        let total = getSum(todayList)
        counterNumber!.scrollToNumber(total.numberBeforeDot, numberAfterDot: total.numberAfterDot)
        
        setupGotoTodayIcon()
    }
    
//  MARK: CalendarWeekViewControllerDelegate
    func selectedDay(_ date: GDate) {
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
            dateLabel!.text = "\(monthName[month - 1]) \(year)"
        }
    }
    
    func nextWeekView() {
        
    }
    
    func prevWeekView() {
        
    }
    
    func CalenderAfterAutoScroll(){
        
    }
}
