//
//  CatagoriesViewController.swift
//  cost
//
//  Created by 郭振永 on 15/12/6.
//  Copyright © 2015年 guozy. All rights reserved.
//

import UIKit
import CoreData

class CatagoriesViewController: UIViewController {
    
    var moc: NSManagedObjectContext!
    
    var contentView: UIView?
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
    
    var catagoriesContent: UIScrollView?
    
    var catagoriesView = CatagoriesEditView(frame: CGRectZero)
    
    
    var kinds: [CatagoriesModel] = [CatagoriesModel]()
    var kindViews: [KindItemView] = [KindItemView]()
    
    var currentView: KindItemView?


    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        view.layer.cornerRadius = 5
        let themeColor = theme.valueForKey(theTheme) as? UIColor
        view.backgroundColor = themeColor?.colorWithAlphaComponent(0.9)
        contentView = UIView(frame: view.frame)
        view.addSubview(contentView!)
        
        if let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext {
            moc = context
        }
        catagoriesView.delegate = self
        
        initTopBar()
        initViews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    
//MARK: init view
    
    func initTopBar() {
        let closeTap = UITapGestureRecognizer(target: self, action: #selector(CatagoriesViewController.JustCloseCatagoriesView(_:)))
        
        let closeButton = UILabel(frame: CGRectMake(10, 27, 30, 30))
        closeButton.userInteractionEnabled = true
        closeButton.text = "✕"
        closeButton.textColor = UIColor.whiteColor()
        closeButton.font = UIFont(name: "Avenir-Heavy", size: 28)!
        closeButton.addGestureRecognizer(closeTap)
        contentView!.addSubview(closeButton)
    }
    
    func initViews() {
        getKinds()
        let margin: CGFloat = 10
        let width: CGFloat = (view.frame.width - margin * 2) / 4
        let height: CGFloat = width
        if catagoriesContent == nil {
            catagoriesContent = UIScrollView(frame: CGRectMake(0, 64, view.frame.width, view.frame.height - 64))
            catagoriesContent?.contentSize = CGSizeMake(view.frame.width, height * CGFloat(kinds.count / 4 + 1))
            catagoriesContent?.setContentOffset(CGPointMake(0, 0), animated: false)
            catagoriesContent?.showsHorizontalScrollIndicator = false
            catagoriesContent?.showsVerticalScrollIndicator = false
            catagoriesContent?.scrollsToTop = false
            catagoriesContent?.directionalLockEnabled = true
            
            contentView!.addSubview(catagoriesContent!)
        } else {
            catagoriesContent?.contentSize = CGSizeMake(view.frame.width, height * CGFloat(kinds.count / 4 + 1))
            for (_, view) in (catagoriesContent?.subviews.enumerate())! {
                view.removeFromSuperview()
            }
            kindViews.removeAll()
        }
        
        
        for (index, item) in kinds.enumerate() {
            var rect: CGRect = CGRectZero
            rect = CGRectMake(CGFloat(index % 4) * width + margin, CGFloat(index / 4) * height, width, height)
            
            let itemView = KindItemView(frame: rect, kind: item.kind, imageName: item.imageName)
            
            let tapKind = UITapGestureRecognizer(target: self, action: #selector(CatagoriesViewController.editKind(_:)))
            itemView.addGestureRecognizer(tapKind)
            
            kindViews.append(itemView)
            
            catagoriesContent?.addSubview(itemView)
        }
    }
    
//MARK: action
    
    func JustCloseCatagoriesView(sender: UITapGestureRecognizer) {
        UIView.animateWithDuration(0.3, animations: {
            self.contentView!.alpha = 0
            self.contentView!.transform = CGAffineTransformMakeScale(0.9, 0.9)
            }, completion: {_ in
                self.dismissViewControllerAnimated(false, completion: nil)
        })
    }
    
    func editKind(sender: UITapGestureRecognizer) {
        let view = sender.view as! KindItemView
        currentView = view
        let themeColor = theme.valueForKey(theTheme) as? UIColor
        let deleteable = canDelete(view.kind!)
        catagoriesView.show(CGRect(x: view.frame.origin.x + 10 + CGFloat(view.frame.width / 2), y: view.frame.origin.y + catagoriesContent!.contentOffset.y + 64 + CGFloat(view.frame.height / 2), width: 0, height: 0), kind: view.kind!, imageName: view.imageName!, bgColor: themeColor!, canDelete: deleteable)
    }

}

extension CatagoriesViewController: CatagoriesEditDelegate {
    func endCatagoriesEdit(kind: String, oldKind: String, imageName: String, delete: Bool) {
        if (delete) {
            deleteKind(oldKind, imageName: imageName)
        } else {
            if (oldKind == "") {
                addKind(kind, imageName: imageName, isInit: false)
            } else {
                saveKind(kind, oldKind: oldKind, imageName: imageName, isInit: false);
            }
        }
    }
    
    func saveKind(kind: String, oldKind: String, imageName: String, isInit: Bool) {
        var kindModel:Catagories?
        let fetchRequest = NSFetchRequest(entityName: "Catagories")
        fetchRequest.predicate = NSPredicate(format: "kind == '\(oldKind)'")
        
        
        var fetchResults: [Catagories]?
        do {
            try fetchResults = (moc.executeFetchRequest(fetchRequest) as! [Catagories])
        } catch let error as NSError {
            print(error)
        }
        
        if fetchResults != nil && fetchResults?.count > 0 {
            kindModel = fetchResults![0]
        } else {
            addKind(kind, imageName: imageName, isInit: isInit)
            return
        }
        if kindModel != nil {
            kindModel!.kind = kind
            kindModel!.imageName = imageName
            
            do {
                try moc.save()
                self.currentView?.imageName = imageName
                self.currentView?.kind = kind
                updateAllItem(kind, oldKind: oldKind)
            } catch let error as NSError {
                print(error)
            }
        }
    }
    
    func addKind(kind: String, imageName: String, isInit: Bool) {
        let itemModel: Catagories = NSEntityDescription.insertNewObjectForEntityForName("Catagories", inManagedObjectContext: moc) as! Catagories
        
        itemModel.kind = kind
        itemModel.imageName = imageName
        
        do {
            try moc.save()
            self.currentView?.kind = kind
            self.currentView?.imageName = imageName
            if !isInit {
                self.initViews()
            }
            
        } catch let error as NSError {
            print(error)
        }
    }
    
    func deleteKind(kind: String, imageName: String) {
        var kindModel:Catagories?
        let fetchRequest = NSFetchRequest(entityName: "Catagories")
        fetchRequest.predicate = NSPredicate(format: "kind == '\(kind)'")
        
        var fetchResults: [Catagories]?
        do {
            try fetchResults = (moc.executeFetchRequest(fetchRequest) as! [Catagories])
        } catch let error as NSError {
            print(error)
        }
        
        if fetchResults != nil && fetchResults?.count > 0 {
            kindModel = fetchResults![0]
        }
        if kindModel != nil {
            moc.deleteObject(kindModel!)
            
            do {
                try moc.save()
                UIView.animateWithDuration(0.3, animations: {
                    self.currentView!.transform = CGAffineTransformMakeScale(0.2, 0.2)
                    }, completion: {_ in
                        self.currentView?.removeFromSuperview()
                        self.initViews()
                })
            } catch let error as NSError {
                print(error)
            }
        }
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
                saveKind(item["kind"]!, oldKind: item["kind"]!, imageName: item["imageName"]!, isInit: true)
            }
        }
        
        let kind = CatagoriesModel()
        kind.imageName = "plus"
        self.kinds.append(kind)
    }
    
    func updateAllItem(kind: String, oldKind: String) {
        let fetchRequest = NSFetchRequest(entityName: "ItemModel")
        
        fetchRequest.predicate = NSPredicate(format: "kind == '\(oldKind)'")
        
        var fetchResults: [ItemModel]?
        do {
            try fetchResults = (moc.executeFetchRequest(fetchRequest) as! [ItemModel])
        } catch let error as NSError {
            print(error)
        }
        
        if (fetchResults != nil && fetchResults?.count > 0) {
            for (_, item) in (fetchResults?.enumerate())! {
                item.kind = kind
            }
        }
        
        do {
            try moc.save()
        } catch let error as NSError {
            print(error)
        }
    }
    
    func canDelete(kind: String) -> Bool {
        if (kind == "") {
            return false
        }
        
        let fetchRequest = NSFetchRequest(entityName: "ItemModel")
        
        fetchRequest.predicate = NSPredicate(format: "kind == '\(kind)' && kill == false")
        
        var fetchResults: [ItemModel]?
        do {
            try fetchResults = (moc.executeFetchRequest(fetchRequest) as! [ItemModel])
        } catch let error as NSError {
            print(error)
        }
        
        if (fetchResults != nil && fetchResults?.count > 0) {
            return false
        } else {
            return true
        }
    }
}
