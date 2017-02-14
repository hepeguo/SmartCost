//
//  CatagoriesViewController.swift
//  cost
//
//  Created by 郭振永 on 15/12/6.
//  Copyright © 2015年 guozy. All rights reserved.
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


class CatagoriesViewController: UIViewController {
    
    var moc: NSManagedObjectContext!
    
    var contentView: UIView?
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
    
    var catagoriesContent: UIScrollView?
    
    var catagoriesView = CatagoriesEditView(frame: CGRect.zero)
    
    
    var kinds: [CatagoriesModel] = [CatagoriesModel]()
    var kindViews: [KindItemView] = [KindItemView]()
    
    var currentView: KindItemView?


    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        view.layer.cornerRadius = 5
        let themeColor = theme.value(forKey: theTheme) as? UIColor
        view.backgroundColor = themeColor?.withAlphaComponent(0.9)
        contentView = UIView(frame: view.frame)
        view.addSubview(contentView!)
        
        if let context = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext {
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
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    
//MARK: init view
    
    func initTopBar() {
        let closeTap = UITapGestureRecognizer(target: self, action: #selector(CatagoriesViewController.JustCloseCatagoriesView(_:)))
        
        let closeButton = UILabel(frame: CGRect(x: 10, y: 27, width: 30, height: 30))
        closeButton.isUserInteractionEnabled = true
        closeButton.text = "✕"
        closeButton.textColor = UIColor.white
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
            catagoriesContent = UIScrollView(frame: CGRect(x: 0, y: 64, width: view.frame.width, height: view.frame.height - 64))
            catagoriesContent?.contentSize = CGSize(width: view.frame.width, height: height * CGFloat(kinds.count / 4 + 1))
            catagoriesContent?.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
            catagoriesContent?.showsHorizontalScrollIndicator = false
            catagoriesContent?.showsVerticalScrollIndicator = false
            catagoriesContent?.scrollsToTop = false
            catagoriesContent?.isDirectionalLockEnabled = true
            
            contentView!.addSubview(catagoriesContent!)
        } else {
            catagoriesContent?.contentSize = CGSize(width: view.frame.width, height: height * CGFloat(kinds.count / 4 + 1))
            for (_, view) in (catagoriesContent?.subviews.enumerated())! {
                view.removeFromSuperview()
            }
            kindViews.removeAll()
        }
        
        
        for (index, item) in kinds.enumerated() {
            var rect: CGRect = CGRect.zero
            rect = CGRect(x: CGFloat(index % 4) * width + margin, y: CGFloat(index / 4) * height, width: width, height: height)
            
            let itemView = KindItemView(frame: rect, kind: item.kind, imageName: item.imageName)
            
            let tapKind = UITapGestureRecognizer(target: self, action: #selector(CatagoriesViewController.editKind(_:)))
            itemView.addGestureRecognizer(tapKind)
            
            kindViews.append(itemView)
            
            catagoriesContent?.addSubview(itemView)
        }
    }
    
//MARK: action
    
    func JustCloseCatagoriesView(_ sender: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.3, animations: {
            self.contentView!.alpha = 0
            self.contentView!.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }, completion: {_ in
                self.dismiss(animated: false, completion: nil)
        })
    }
    
    func editKind(_ sender: UITapGestureRecognizer) {
        let view = sender.view as! KindItemView
        currentView = view
        let themeColor = theme.value(forKey: theTheme) as? UIColor
        let deleteable = canDelete(view.kind!)
        catagoriesView.show(CGRect(x: view.frame.origin.x + 10 + CGFloat(view.frame.width / 2), y: view.frame.origin.y + catagoriesContent!.contentOffset.y + 64 + CGFloat(view.frame.height / 2), width: 0, height: 0), kind: view.kind!, imageName: view.imageName!, bgColor: themeColor!, canDelete: deleteable)
    }

}

extension CatagoriesViewController: CatagoriesEditDelegate {
    func endCatagoriesEdit(_ kind: String, oldKind: String, imageName: String, delete: Bool) {
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
    
    func saveKind(_ kind: String, oldKind: String, imageName: String, isInit: Bool) {
        var kindModel:Catagories?
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Catagories")
        fetchRequest.predicate = NSPredicate(format: "kind == '\(oldKind)'")
        
        
        var fetchResults: [Catagories]?
        do {
            try fetchResults = (moc.fetch(fetchRequest) as! [Catagories])
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
    
    func addKind(_ kind: String, imageName: String, isInit: Bool) {
        let itemModel: Catagories = NSEntityDescription.insertNewObject(forEntityName: "Catagories", into: moc) as! Catagories
        
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
    
    func deleteKind(_ kind: String, imageName: String) {
        var kindModel:Catagories?
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Catagories")
        fetchRequest.predicate = NSPredicate(format: "kind == '\(kind)'")
        
        var fetchResults: [Catagories]?
        do {
            try fetchResults = (moc.fetch(fetchRequest) as! [Catagories])
        } catch let error as NSError {
            print(error)
        }
        
        if fetchResults != nil && fetchResults?.count > 0 {
            kindModel = fetchResults![0]
        }
        if kindModel != nil {
            moc.delete(kindModel!)
            
            do {
                try moc.save()
                UIView.animate(withDuration: 0.3, animations: {
                    self.currentView!.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
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
                saveKind(item["kind"]!, oldKind: item["kind"]!, imageName: item["imageName"]!, isInit: true)
            }
        }
        
        let kind = CatagoriesModel()
        kind.imageName = "plus"
        self.kinds.append(kind)
    }
    
    func updateAllItem(_ kind: String, oldKind: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ItemModel")
        
        fetchRequest.predicate = NSPredicate(format: "kind == '\(oldKind)'")
        
        var fetchResults: [ItemModel]?
        do {
            try fetchResults = (moc.fetch(fetchRequest) as! [ItemModel])
        } catch let error as NSError {
            print(error)
        }
        
        if (fetchResults != nil && fetchResults?.count > 0) {
            for (_, item) in (fetchResults?.enumerated())! {
                item.kind = kind
            }
        }
        
        do {
            try moc.save()
        } catch let error as NSError {
            print(error)
        }
    }
    
    func canDelete(_ kind: String) -> Bool {
        if (kind == "") {
            return false
        }
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ItemModel")
        
        fetchRequest.predicate = NSPredicate(format: "kind == '\(kind)' && kill == false")
        
        var fetchResults: [ItemModel]?
        do {
            try fetchResults = (moc.fetch(fetchRequest) as! [ItemModel])
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
