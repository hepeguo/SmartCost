//
//  NewItemViewController.swift
//  $Mate
//
//  Created by 郭振永 on 15/3/15.
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


class NewItemViewController: UIViewController, NumberPadDelegate, UITextViewDelegate {
    
    lazy var item: Item = Item()
    var addButton: UILabel?
    var priceLabel: UILabel?
    var detailTextView: UITextView?
    var deleteButton: UILabel?
    var numberPad: NumberPad?
    var contentView: UIView?
    
    var kinds: [CatagoriesModel] = [CatagoriesModel]()
    var kindViews: [KindItemView] = [KindItemView]()
    var kindViewsPageView: PageView?
    
    var priceLabelBorder: UIView?
    var detailTextViewBg: UIView?
    
    var detailTap: UIGestureRecognizer?
    
    var justClose: Bool = false
    
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
    
    var moc: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //prevent VerticalScroll
        self.automaticallyAdjustsScrollViewInsets = false
        view.layer.cornerRadius = 5
        view.backgroundColor = theme.value(forKey: theTheme) as? UIColor
        contentView = UIView(frame: view.frame)
        view.addSubview(contentView!)
        
        if let context = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext {
            moc = context
        }
        getKinds()
        
        initTopBar()
        initKindView()
        initFormViews()
        
        if item.id != "" {
            setUpViews()
        }
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
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
//MARK: init views
    func initTopBar() {
        let closeTap = UITapGestureRecognizer(target: self, action: #selector(NewItemViewController.JustCloseAddItemView(_:)))
        
        let closeButton = UILabel(frame: CGRect(x: 10, y: 27, width: 30, height: 30))
        closeButton.isUserInteractionEnabled = true
        closeButton.text = "✕"
        closeButton.textColor = UIColor.white
        closeButton.font = UIFont(name: "Avenir-Heavy", size: 28)!
        closeButton.addGestureRecognizer(closeTap)
        contentView!.addSubview(closeButton)
        
        let addTap = UITapGestureRecognizer(target: self, action: #selector(NewItemViewController.closeAddItemViewWithNewer(_:)))
        addButton = UILabel(frame: CGRect(x: view.frame.width - 60, y: 27, width: 50, height: 30))
        addButton?.isUserInteractionEnabled = true
        addButton?.text = "ADD"
        addButton?.textAlignment = .right
        addButton?.textColor = UIColor.white
        addButton?.font = UIFont(name: "Avenir-Heavy", size: 18)!
        addButton?.addGestureRecognizer(addTap)
        addButton?.alpha = 0
        contentView!.addSubview(addButton!)
    }
    
    func initFormViews() {
        priceLabelBorder = UILabel(frame: CGRect(x: 10, y: 84, width: view.frame.width - 20, height: 44))
        priceLabelBorder?.isUserInteractionEnabled = true
        priceLabelBorder?.layer.borderWidth = 2
        priceLabelBorder?.layer.borderColor = UIColor.white.cgColor
        
        priceLabel = UILabel(frame: CGRect(x: 5, y: 0, width: view.frame.width - 30, height: 44))
        priceLabel?.text = "0"
        priceLabel?.font = UIFont(name: "Avenir-Heavy", size: 30)!
        priceLabel?.textColor = UIColor.white
        priceLabel?.textAlignment = .right
        priceLabel?.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(NewItemViewController.showNumberPad(_:)))
        priceLabel?.addGestureRecognizer(tap)
        
        priceLabelBorder?.addSubview(priceLabel!)
        contentView!.addSubview(priceLabelBorder!)
        
        detailTextViewBg = UILabel(frame: CGRect(x: 10, y: 140 + kindViewsPageView!.frame.height, width: view.frame.width - 20, height: 88))
        detailTextViewBg?.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
        detailTextViewBg?.isUserInteractionEnabled = true
        
        detailTextView = UITextView(frame: CGRect(x: 5, y: 0, width: view.frame.width - 30, height: 88))
        detailTextView?.textColor = UIColor.white
        detailTextView?.backgroundColor = UIColor.clear
        detailTextView?.font = UIFont(name: "Avenir-Heavy", size: 18)!
        detailTextView?.isUserInteractionEnabled = true
        detailTextView?.returnKeyType = .done
        detailTextView?.delegate = self
        detailTap = UITapGestureRecognizer(target: self, action: #selector(NewItemViewController.detailTapped(_:)))
        detailTextView?.addGestureRecognizer(detailTap!)
        detailTextViewBg?.addSubview(detailTextView!)
        contentView?.addSubview(detailTextViewBg!)
        
        deleteButton = UILabel(frame: CGRect(x: 10, y: view.frame.height - 64, width: view.frame.width - 20, height: 44))
        deleteButton?.text = "DELETE"
        deleteButton?.textColor = UIColor.red
        deleteButton?.textAlignment = .center
        deleteButton?.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        deleteButton?.isUserInteractionEnabled = true
        let deleteTap = UITapGestureRecognizer(target: self, action: #selector(NewItemViewController.deleteItem(_:)))
        deleteButton?.addGestureRecognizer(deleteTap)
        deleteButton?.isHidden = true
        contentView?.addSubview(deleteButton!)
        
        numberPad = NumberPad(frame: CGRect(x: 0, y: view.frame.height / 2 + 20, width: view.frame.width, height: view.frame.height / 2 - 20))
        numberPad?.layer.zPosition = 2
        numberPad?.delegate = self
        contentView!.addSubview(numberPad!)
    }
    
    func initKindView() {
        let width = view.frame.width / 5
        let height = width - 15
        
        var kindViewContentFirst = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: height * CGFloat(2)))
        var views = [UIView]()
        views.append(kindViewContentFirst)
        for (index, item) in kinds.enumerated() {
            var rect: CGRect = CGRect.zero
            let newIndex = index - 10 * (index / 10)
            rect = CGRect(x: CGFloat(newIndex % 5) * width, y: CGFloat(newIndex / 5) * height, width: width, height: height)
            
            let itemView = KindItemView(frame: rect, kind: item.kind, imageName: item.imageName)
            
            let tapKind = UITapGestureRecognizer(target: self, action: #selector(NewItemViewController.selectKind(_:)))
            itemView.addGestureRecognizer(tapKind)
            
            kindViews.append(itemView)
            
            kindViewContentFirst.addSubview(itemView)
            if kindViewContentFirst.subviews.count >= 10 && index < kinds.count - 1 {
                kindViewContentFirst = UIView(frame: CGRect(x: view.frame.width * CGFloat(index / 10), y: 0, width: view.frame.width, height: height * CGFloat(2)))
                views.append(kindViewContentFirst)
            }
        }
        kindViewsPageView = PageView(frame: CGRect(x: 0, y: 135, width: view.frame.width, height: kindViewContentFirst.frame.height + CGFloat(20) ), views: views)
        contentView!.addSubview(kindViewsPageView!)
    }
    
    func setUpViews() {
        let priceString = NSString(format: "%.2f", item.price)
        priceLabel?.text = priceString as String
        addButton?.text = "SAVE"
        addButton?.alpha = 1
        numberPad?.frame.origin.y = view.frame.height
        numberPad?.isHidden = true
        detailTextView?.text = item.detail
        deleteButton?.isHidden = false
        for (index, kindView) in kindViews.enumerated() {
            if kindView.kind == item.kind {
                let pages = index / 10
                kindViewsPageView?.scrollTo(CGPoint(x: view.frame.width * CGFloat(pages), y: 0))
                kindView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
            }
        }
    }
    
//MARK: actions
    func JustCloseAddItemView(_ sender: UITapGestureRecognizer) {
        justClose = true
        detailTextView?.resignFirstResponder()
        self.numberPad?.frame.origin.y = self.view.frame.height
        UIView.animate(withDuration: 0.3, animations: {
            self.contentView!.alpha = 0
            self.contentView!.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }, completion: {_ in
                self.performSegue(withIdentifier: "closeNewItemView", sender: self)
        })
    }
    
    func closeAddItemViewWithNewer(_ sender: UITapGestureRecognizer) {
        detailTextView?.resignFirstResponder()
        let price = priceLabel!.text!
        item.price = (price as NSString).floatValue
        item.detail = detailTextView!.text
        item.kill = false
        
        UIView.animate(withDuration: 0.3, animations: {
            self.contentView!.alpha = 0
            self.contentView!.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }, completion: {_ in
                self.performSegue(withIdentifier: "closeNewItemView", sender: self)
        })
    }
    
    func deleteItem(_ sender: UITapGestureRecognizer) {
        detailTextView?.resignFirstResponder()
        item.kill = true
        
        UIView.animate(withDuration: 0.3, animations: {
            self.contentView!.alpha = 0
            self.contentView!.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }, completion: {_ in
                self.performSegue(withIdentifier: "closeNewItemView", sender: self)
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if item.price != 0 {
            let mainViewController = segue.destination as! MainViewController
            if (!justClose) {
                mainViewController.newItemFromAddView(self.item)
            }
        }
    }
    
    func showNumberPad(_ sender: UITapGestureRecognizer) {
        detailTextView?.resignFirstResponder()
        if numberPad?.isHidden == true {
            numberPad?.isHidden = false
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.55, initialSpringVelocity: 0.1, options: UIViewAnimationOptions.beginFromCurrentState, animations: {
                self.numberPad?.frame.origin.y = self.view.frame.height / 2 + 20
                }, completion: nil)
        }
    }
    
    func selectKind(_ sender: UITapGestureRecognizer) {
        detailTextView?.resignFirstResponder()
        let view = sender.view as! KindItemView
        for (_, kindView) in kindViews.enumerated() {
            kindView.backgroundColor = UIColor.clear
        }
        view.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
        item.kind = view.kind!
        if priceLabel?.text != "0" && priceLabel?.text != "" {
            if addButton?.alpha == 1 {
                return
            }
            UIView.animate(withDuration: 0.3, animations: {
                self.addButton?.alpha = 1
                }, completion: nil)
        }
    }
    
    func detailTapped(_ sender: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.3, animations: {
            self.numberPad?.frame.origin.y = self.view.frame.height
            self.priceLabelBorder?.frame.origin.y = -(140 + self.kindViewsPageView!.frame.height + 135)
            self.kindViewsPageView?.frame.origin.y = -(140 + self.kindViewsPageView!.frame.height)
            self.detailTextViewBg?.frame.origin.y = 84
            }, completion: { _ in
                self.numberPad?.isHidden = true
                self.detailTextView?.becomeFirstResponder()
                self.detailTextView?.removeGestureRecognizer(self.detailTap!)
        })
    }

//MARK: numberPad delegate
    func tappedNumber(_ text: String) {
        priceLabel?.text = text
        if priceLabel?.text != "0" && priceLabel?.text != "" {
            if addButton?.alpha == 1 {
                return
            }
            if item.kind != "" {
                UIView.animate(withDuration: 0.3, animations: {
                    self.addButton?.alpha = 1
                    }, completion: nil)
            }
        } else {
            if addButton?.alpha == 0 {
                return
            }
            UIView.animate(withDuration: 0.3, animations: {
                self.addButton?.alpha = 0
                }, completion: nil)
        }
    }
    
    func tappedOK() {
        UIView.animate(withDuration: 0.3, animations: {
            self.numberPad?.frame.origin.y = self.view.frame.height
            }, completion: { _ in
                self.numberPad?.isHidden = true
        })
    }
    
//MARK: press done hide keyboard
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            UIView.animate(withDuration: 0.3, animations: {
                self.priceLabelBorder?.frame.origin.y = 84
                self.kindViewsPageView?.frame.origin.y = 135
                self.detailTextViewBg?.frame.origin.y = 140 + self.kindViewsPageView!.frame.height
                }, completion: { _ in
//                    self.numberPad?.hidden = true
//                    self.detailTextView?.becomeFirstResponder()
                    self.detailTextView?.addGestureRecognizer(self.detailTap!)
            })

            return false;
        }
        return true;
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
}
