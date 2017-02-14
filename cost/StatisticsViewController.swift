//
//  StatisticsViewController.swift
//  cost
//
//  Created by 郭振永 on 15/5/12.
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
    
    var moc: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        view.backgroundColor = theme.value(forKey: theTheme) as? UIColor
        contentView = UIView(frame: view.frame)
        view.addSubview(contentView!)
        let tap = UITapGestureRecognizer(target: self, action: #selector(StatisticsViewController.hideDateSelectView(_:)))
        view.addGestureRecognizer(tap)
        
        if let context = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext {
            moc = context
        }
        getKinds()
        
        initTopBar()
        initStatisticsView()
        initTableView()
        initDateSelectView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        contentView!.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        UIView.animate(withDuration: 0.3, animations: {
            self.contentView!.transform = CGAffineTransform(scaleX: 1, y: 1)
            }, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
//MARK: init views
    
    func initTopBar() {
        let closeTap = UITapGestureRecognizer(target: self, action: #selector(StatisticsViewController.JustCloseStatisticsView(_:)))
        
        let closeButton = UILabel(frame: CGRect(x: 10, y: 27, width: 30, height: 30))
        closeButton.isUserInteractionEnabled = true
        closeButton.text = "✕"
        closeButton.textColor = UIColor.white
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
        
        let counterRect: CGRect = CGRect(x: view.frame.width / 2 - 100, y: 20, width: 200, height: 200)
        counterView = CounterView(frame: counterRect)
        let dataList = getMonthDataFromDatabase(year, month: month)
        kindAndSum = comboData(dataList!)
        counterView!.numbers = kindAndSum!
        counterView!.backgroundColor = UIColor.clear
        
        contentView?.addSubview(counterView!)
        
        yearLabel = UILabel(frame: CGRect(x: 10, y: 180, width: 100, height: 20))
        yearLabel?.text = "Y: \(day.year)"
        yearLabel?.textColor = UIColor.white
        yearLabel?.font = UIFont(name: "Avenir-Heavy", size: 18)!
        yearLabel?.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
        yearLabel?.layer.cornerRadius = 4
        yearLabel?.layer.masksToBounds = true
        yearLabel?.textAlignment = .center
        yearLabel?.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(StatisticsViewController.showYearSelectView(_:)))
        yearLabel?.addGestureRecognizer(tap)
        contentView?.addSubview(yearLabel!)
        
        monthLabel = UILabel(frame: CGRect(x: view.frame.width - 110, y: 180, width: 100, height: 20))
        monthLabel?.text = "M: \(day.month)"
        monthLabel?.layer.cornerRadius = 4
        monthLabel?.layer.masksToBounds = true
        monthLabel?.textAlignment = .center
        monthLabel?.textColor = UIColor.white
        monthLabel?.font = UIFont(name: "Avenir-Heavy", size: 18)!
        monthLabel?.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
        monthLabel?.isUserInteractionEnabled = true
        let tapMonth = UITapGestureRecognizer(target: self, action: #selector(StatisticsViewController.showMonthSelectView(_:)))
        monthLabel?.addGestureRecognizer(tapMonth)
        contentView?.addSubview(monthLabel!)
    }
    
    func initTableView() {
        tableView = UITableView(frame: CGRect(x: 0, y: 220, width: view.frame.width, height: view.frame.height - 220))
        tableView!.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView!.dataSource = self
        tableView!.delegate = self
        contentView!.addSubview(tableView!)
    }
    
    func initDateSelectView() {
        let date = GDate()
        let day = date.getDay()
        let startYear = 2010
        let length = 100
        yearSelectView = UIScrollView(frame: CGRect(x: 10, y: 200, width: 0, height: 0))
        yearSelectView?.contentSize = CGSize(width: 50, height: 30 * CGFloat(length))
        yearSelectView?.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        yearSelectView?.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        yearSelectView?.layer.cornerRadius = 4
        yearSelectView?.alpha = 0
        
        yearSelectView?.showsHorizontalScrollIndicator = false
        yearSelectView?.showsVerticalScrollIndicator = false
        yearSelectView?.scrollsToTop = false
        yearSelectView?.isDirectionalLockEnabled = true
        yearSelectView?.delegate = self
        
        for i in startYear ..< startYear + length {
            let label = UILabel(frame: CGRect(x: 0, y: CGFloat(i - startYear) * 30, width: 100, height: 30))
            label.text = "\(i)"
            label.textAlignment = .center
            label.font = UIFont(name: "Avenir-Heavy", size: 18)!
            label.textColor = UIColor.white
            label.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(StatisticsViewController.selectYear(_:)))
            label.addGestureRecognizer(tap)
            
            if i == day.year {
                label.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
                yearSelectView?.setContentOffset(CGPoint(x: 0, y: CGFloat(i - startYear) * 30), animated: false)
            }
            yearsView.append(label)
            yearSelectView?.addSubview(label)
        }
        contentView?.addSubview(yearSelectView!)
        
        monthSelectView = UIScrollView(frame: CGRect(x: view.frame.width - 10, y: 200, width: 0, height: 0))
        monthSelectView?.contentSize = CGSize(width: 50, height: 30 * CGFloat(12))
        monthSelectView?.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        monthSelectView?.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        monthSelectView?.layer.cornerRadius = 4
        monthSelectView?.alpha = 0
        
        monthSelectView?.showsHorizontalScrollIndicator = false
        monthSelectView?.showsVerticalScrollIndicator = false
        monthSelectView?.scrollsToTop = false
        monthSelectView?.isDirectionalLockEnabled = true
        monthSelectView?.delegate = self
        
//        for var i = 1; i <= 12; i += 1 {
        for i in 1 ..< 12 {
            let label = UILabel(frame: CGRect(x: 0, y: CGFloat(i - 1) * 30, width: 100, height: 30))
            label.text = "\(i)"
            label.textAlignment = .center
            label.font = UIFont(name: "Avenir-Heavy", size: 18)!
            label.textColor = UIColor.white
            label.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(StatisticsViewController.selectMonth(_:)))
            label.addGestureRecognizer(tap)
            if i == day.month {
                label.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
                monthSelectView?.setContentOffset(CGPoint(x: 0, y: CGFloat(i - 1) * 30), animated: false)
            }
            monthsView.append(label)
            monthSelectView?.addSubview(label)
        }
        contentView?.addSubview(monthSelectView!)
    }
    
//MARK: action
    
    func JustCloseStatisticsView(_ sender: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.3, animations: {
            self.contentView!.alpha = 0
            self.contentView!.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }, completion: {_ in
                self.performSegue(withIdentifier: "closeStatisticsView", sender: self)
        })
    }
    
    func showYearSelectView(_ sender: UITapGestureRecognizer) {
        if yearSelectView?.alpha == 1 {
            UIView.animate(withDuration: 0.3, animations: {
                self.yearSelectView?.alpha = 0
                self.yearSelectView?.frame.size = CGSize(width: 0, height: 0)
                }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.yearSelectView?.alpha = 1
                self.yearSelectView?.frame.size = CGSize(width: 100, height: 200)
            }, completion: nil)
        }
    }
    
    func showMonthSelectView(_ sender: UITapGestureRecognizer) {
        if monthSelectView?.alpha == 1 {
            UIView.animate(withDuration: 0.3, animations: {
                self.monthSelectView?.alpha = 0
                self.monthSelectView?.frame = CGRect(x: self.view.frame.width - 10, y: 200, width: 0, height: 0)
            }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.monthSelectView?.alpha = 1
                self.monthSelectView?.frame = CGRect(x: self.view.frame.width - 110, y: 200, width: 100, height: 200)
            }, completion: nil)
        }
    }
    
    func selectYear(_ sender: UITapGestureRecognizer) {
        for (_, view) in yearsView.enumerated() {
            view.backgroundColor = UIColor.clear
        }
        let label = sender.view as! UILabel
        label.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        UIView.animate(withDuration: 0.3, animations: {
            self.yearSelectView?.alpha = 0
            self.yearSelectView?.frame.size = CGSize(width: 0, height: 0)
            }, completion: {_ in
                self.yearLabel?.text = "Y: " + label.text!
                self.year = Int(label.text!)!
                let dataList = self.getMonthDataFromDatabase(self.year, month: self.month)
                self.kindAndSum = self.comboData(dataList!)
                self.counterView!.numbers = self.kindAndSum!
        })
    }
    
    func selectMonth(_ sender: UITapGestureRecognizer) {
        for (_, view) in monthsView.enumerated() {
            view.backgroundColor = UIColor.clear
        }
        let label = sender.view as! UILabel
        label.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        UIView.animate(withDuration: 0.3, animations: {
            self.monthSelectView?.alpha = 0
            self.monthSelectView?.frame = CGRect(x: self.view.frame.width - 10, y: 200, width: 0, height: 0)
            }, completion: {_ in
                self.monthLabel?.text = "M: " + label.text!
                self.month = Int(label.text!)!
                let dataList = self.getMonthDataFromDatabase(self.year, month: self.month)
                self.kindAndSum = self.comboData(dataList!)
                self.counterView!.numbers = self.kindAndSum!
        })
    }
    
    func hideDateSelectView(_ sender: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.3, animations: {
            self.monthSelectView?.alpha = 0
            self.monthSelectView?.frame = CGRect(x: self.view.frame.width - 10, y: 200, width: 0, height: 0)
            }, completion: nil)
        UIView.animate(withDuration: 0.3, animations: {
            self.yearSelectView?.alpha = 0
            self.yearSelectView?.frame.size = CGSize(width: 0, height: 0)
            }, completion: nil)
    }
    
//MARK: get data from database
    
    func getWeekDataFromDatabase(_ year: Int, weekOfYear: Int) -> [ItemModel]? {
//        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ItemModel")
        
        fetchRequest.predicate = NSPredicate(format: "year == '\(year)' && weekOfYear == '\(weekOfYear)' && kill == false")
        
        var fetchResults: [ItemModel]?
        do {
            try fetchResults = (moc.fetch(fetchRequest) as! [ItemModel])
        } catch let error as NSError {
            print(error)
        }
        return fetchResults
    }
    
    func getMonthDataFromDatabase(_ year: Int, month: Int) -> [ItemModel]? {
//        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ItemModel")
        
        fetchRequest.predicate = NSPredicate(format: "year == '\(year)' && month == '\(month)' && kill == false")
        
        var fetchResults: [ItemModel]?
        do {
            try fetchResults = (moc.fetch(fetchRequest) as! [ItemModel])
        } catch let error as NSError {
            print(error)
        }
        
        return fetchResults
    }
    
    func getYearDataFromDatabase(_ year: Int) -> [ItemModel]? {
//        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ItemModel")
        
        fetchRequest.predicate = NSPredicate(format: "year == '\(year)' && kill == false")
        
        var fetchResults: [ItemModel]?
        do {
            try fetchResults = (moc.fetch(fetchRequest) as! [ItemModel])
        } catch let error as NSError {
            print(error)
        }
        return fetchResults
    }
    
    func comboData(_ data: [ItemModel]) -> [Kind] {
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
    
    func getSum (_ data: [ItemModel]) -> (numberBeforeDot: Int, numberAfterDot: Int) {
        var sum: Float = 0.0
        var numberBeforeDot = 0
        var numberAfterDot = 0
        for itemModel in data {
            sum += itemModel.price.floatValue
        }
        numberBeforeDot = Int(sum)
        let totalString = "\(sum)" as NSString
        let location = [totalString .range(of: ".")].first?.location
        let stringAfterDot = totalString.substring(from: location! + 1)
        numberAfterDot = Int(stringAfterDot)!
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

//MARK: tableView delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return kindAndSum!.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "cell")
        let kind: Kind = kindAndSum![indexPath.row];
        cell.textLabel?.text = kind.name
        
        let view = UIView(frame: CGRect(x: 10, y: 10, width: 40, height: 40))
        view.backgroundColor = UIColor.colorFromCode(colors[indexPath.row])
        let imageView = UIImageView(frame: CGRect(x: 5, y: 5, width: 30, height: 30))
        imageView.image = UIImage(named: getKingIamgeName(kind.name))
        view.addSubview(imageView)
        view.layer.cornerRadius = 10
        cell.addSubview(view)
        
        cell.imageView?.image = UIImage(named: "Film")
        let priceString = String(format: "%.2f", kind.sum)
        cell.detailTextLabel?.text = priceString as String
        cell.detailTextLabel?.textColor = UIColor.gray
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if (scrollView == tableView) {
            UIView.animate(withDuration: 0.3, animations: {
                self.monthSelectView?.alpha = 0
                self.monthSelectView?.frame = CGRect(x: self.view.frame.width - 10, y: 200, width: 0, height: 0)
                }, completion: nil)
            UIView.animate(withDuration: 0.3, animations: {
                self.yearSelectView?.alpha = 0
                self.yearSelectView?.frame.size = CGSize(width: 0, height: 0)
                }, completion: nil)
        }
        
    }
}
