//
//  CatagoriesEditView.swift
//  cost
//
//  Created by 郭振永 on 15/12/6.
//  Copyright © 2015年 guozy. All rights reserved.
//

import UIKit

protocol CatagoriesEditDelegate {
    func endCatagoriesEdit(kind: String, oldKind: String, imageName: String, delete: Bool)
}

class CatagoriesEditView: UIView {
    
    
    var addButton: UILabel?
    var closeButton: UILabel?
    
    var allImage: [String] = ["Film","Food","Snacks","Clothing","Shopping","Gifts","Digital","Home","Study","Traffic","Travel","Entertainment","Net Fee","Visa","Investment","Medicine","Social","Transfer","Fine","Other", "address-book","aid-kit","airplane","barcode","books","bubbles","bug","bullhorn","camera","cart","connection","credit-card","database","dice","display","envelop","film-1","floppy-disk","gift","glass","glass2","hammer","hammer2","headphones","heart-broken","heart","home-1","iconfont-3","iconfont-bus-copy","iconfont-jiaotong","iconfont-jiaotong1","iconfont-jiaotongiconsubway","image","key2","keyboard","laptop","library","man","mic","mobile","mobile2","mug","music","newspaper","office","paint-format","pen","pencil","pencil2","phone","play","power-cord","price-tags","printer","qrcode","quill","spoon-knife","tablet","trophy","truck","tv","video-camera","woman"]
    
    var kind: String?
    var oldKind: String = ""
    var imageName: String?
    
    var kindLabel: UITextField?
    
    var deleteButton: UILabel?
    
    var bgView: UIView?
    
    var originFrame: CGRect = CGRectZero
    
    var isFirst: Bool = true
    
    var imagesContent: UIScrollView?
    var kindViews: [KindItemView] = [KindItemView]()
    
    var kindLabelTap: UITapGestureRecognizer?
    
    var delegate:CatagoriesEditDelegate?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = 5
        bgView = UIView(frame: CGRectMake(0, 0, CGRectGetWidth(UIScreen.mainScreen().bounds), CGRectGetHeight(UIScreen.mainScreen().bounds)))
        bgView?.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.75)
        self.clipsToBounds = true
        
        initTopBar()
        initImageViews()
        initView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initImageViews() {
        let screenWidth = CGRectGetWidth(UIScreen.mainScreen().bounds)
        let screenHeight = CGRectGetHeight(UIScreen.mainScreen().bounds)
        
        let margin: CGFloat = 10
        let numberInline: CGFloat = 4
        let width: CGFloat = (screenWidth - margin * 4) / numberInline
        let height: CGFloat = width
        
        imagesContent = UIScrollView(frame: CGRectMake(10, 44, screenWidth - 40, screenHeight - 232))
        imagesContent?.contentSize = CGSizeMake(screenWidth - 40, height * CGFloat(allImage.count / Int(numberInline) + 1))
        imagesContent?.setContentOffset(CGPointMake(0, 0), animated: false)
        imagesContent?.showsHorizontalScrollIndicator = false
        imagesContent?.showsVerticalScrollIndicator = false
        imagesContent?.scrollsToTop = false
        imagesContent?.directionalLockEnabled = true
        imagesContent?.hidden = true
        
        self.addSubview(imagesContent!)
        
        for (index, item) in allImage.enumerate() {
            var rect: CGRect = CGRectZero
            rect = CGRectMake(CGFloat(index % Int(numberInline)) * width, CGFloat(index / Int(numberInline)) * height, width, height)
            
            let itemView = KindItemView(frame: rect, imageName: item)
            
            let tapKind = UITapGestureRecognizer(target: self, action: "selectImage:")
            itemView.addGestureRecognizer(tapKind)
            
            kindViews.append(itemView)
            
            imagesContent?.addSubview(itemView)
        }
        self.addSubview(imagesContent!)
    }
    
    func initView() {
        kindLabel = UITextField(frame: CGRect(x: 10, y: CGRectGetMaxY(imagesContent!.frame) + 10, width: CGRectGetWidth(imagesContent!.frame), height: 44))
        kindLabel?.layer.borderWidth = 2
        kindLabel?.layer.borderColor = UIColor.whiteColor().CGColor
        kindLabel?.font = UIFont(name: "Avenir-Heavy", size: 18)!
        kindLabel?.userInteractionEnabled = true
        kindLabel?.returnKeyType = .Done
        kindLabel?.textColor = UIColor.whiteColor()
        kindLabel?.addTarget(self, action: "doneClicked:", forControlEvents: UIControlEvents.EditingDidEndOnExit)
        kindLabel?.addTarget(self, action: "kindLabelTapped:", forControlEvents: .EditingDidBegin)
        kindLabelTap = UITapGestureRecognizer(target: self, action: "kindLabelTapped:")
        kindLabel?.addGestureRecognizer(kindLabelTap!)
        
        let spacerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height:10))
        kindLabel?.leftViewMode = .Always
        kindLabel?.leftView = spacerView
        self.kindLabel?.hidden = true
        
        self.addSubview(kindLabel!)
        
        deleteButton = UILabel(frame: CGRect(x: 10, y: CGRectGetMaxY(kindLabel!.frame) + 10, width: CGRectGetWidth(imagesContent!.frame), height: 44))
        deleteButton?.text = "DELETE"
        deleteButton?.textAlignment = .Center
        deleteButton?.textColor = UIColor.whiteColor()
        deleteButton?.font = UIFont(name: "Avenir-Heavy", size: 18)!
        deleteButton?.userInteractionEnabled = true
        deleteButton?.hidden = true
        let deleteKindLabelTap = UITapGestureRecognizer(target: self, action: "deleteKind:")
        deleteButton?.addGestureRecognizer(deleteKindLabelTap)
        
        self.addSubview(deleteButton!)
    }
    
    func initTopBar() {
        let closeTap = UITapGestureRecognizer(target: self, action: "JustCloseEditView:")
        
        closeButton = UILabel(frame: CGRectMake(10, 10, 30, 30))
        closeButton?.userInteractionEnabled = true
        closeButton?.text = "✕"
        closeButton?.textColor = UIColor.whiteColor()
        closeButton?.font = UIFont(name: "Avenir-Heavy", size: 28)!
        closeButton?.addGestureRecognizer(closeTap)
        self.addSubview(closeButton!)
        
        let addTap = UITapGestureRecognizer(target: self, action: "closeEditWithNewer:")
        addButton = UILabel(frame: CGRectZero)
        addButton?.userInteractionEnabled = true
        addButton?.text = "SAVE"
        addButton?.textAlignment = .Right
        addButton?.textColor = UIColor.whiteColor()
        addButton?.font = UIFont(name: "Avenir-Heavy", size: 18)!
        addButton?.addGestureRecognizer(addTap)
        self.addSubview(addButton!)
    }
    
    func selectImage(sender: UITapGestureRecognizer) {
        let view = sender.view as! KindItemView
        for (_, kindView) in kindViews.enumerate() {
            kindView.backgroundColor = UIColor.clearColor()
        }
        view.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
        self.imageName = view.imageName!
        if trim(kindLabel!.text!) != "" {
            addButton?.hidden = false
        }
    }
    
    func setImage(imageName: String) {
        var has = false
        for (_, kindView) in kindViews.enumerate() {
            if kindView.imageName == imageName {
                kindView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
                has = true
            } else {
                kindView.backgroundColor = UIColor.clearColor()
            }
        }
        if !has {
            addButton?.hidden = true
        }
    }
    
    func kindLabelTapped(sender: UIGestureRecognizer) {
        UIView.animateWithDuration(0.3, animations: {
            self.imagesContent?.frame.origin.y = -(self.imagesContent!.frame.height + (self.kindLabel?.frame.height)! + 44)
            self.kindLabel?.frame.origin.y = 44
            self.deleteButton?.frame.origin.y = CGRectGetMaxY(self.kindLabel!.frame) + 10
            self.addButton?.hidden = true
            }, completion: { _ in
                self.kindLabel?.removeGestureRecognizer(self.kindLabelTap!)
                self.kindLabel?.becomeFirstResponder()
        })
    }
    
    func JustCloseEditView(sender: UITapGestureRecognizer) {
        imagesContent?.hidden = true
        self.kindLabel?.hidden = true
        self.deleteButton?.hidden = true
        self.kindLabel?.resignFirstResponder()
        UIView.animateWithDuration(0.25, animations: {
            self.frame = self.originFrame
            self.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.75)
            self.closeButton?.hidden = true
            self.bgView?.hidden = true
            self.addButton?.frame = CGRectZero
            self.addButton?.hidden = true
        }, completion: { _ in
            self.hidden = true
        })
    }
    
    func closeEditWithNewer(sender: UITapGestureRecognizer) {
        self.kindLabel?.resignFirstResponder()
        if kindLabel?.text != nil {
            imagesContent?.hidden = true
            self.kindLabel?.hidden = true
            self.deleteButton?.hidden = true
            UIView.animateWithDuration(0.25, animations: {
                self.frame = self.originFrame
                self.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.75)
                self.closeButton?.hidden = true
                self.bgView?.hidden = true
                self.addButton?.frame = CGRectZero
                self.addButton?.hidden = true
                }, completion: { _ in
                    self.hidden = true
                    self.delegate?.endCatagoriesEdit((self.kindLabel?.text)!, oldKind: self.oldKind, imageName: self.imageName!, delete: false)
            })
        }
    }
    
    func deleteKind(sender: UITapGestureRecognizer) {
        imagesContent?.hidden = true
        self.kindLabel?.hidden = true
        self.deleteButton?.hidden = true
        UIView.animateWithDuration(0.25, animations: {
            self.frame = self.originFrame
            self.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.75)
            self.closeButton?.hidden = true
            self.bgView?.hidden = true
            self.addButton?.frame = CGRectZero
            self.addButton?.hidden = true
            }, completion: { _ in
                self.hidden = true
                self.delegate?.endCatagoriesEdit((self.kindLabel?.text)!, oldKind: self.oldKind, imageName: self.imageName!, delete: true)
        })
    }
    
    
    func show(frame: CGRect, kind: String, imageName: String, bgColor: UIColor, canDelete: Bool) {
        self.frame = frame
        self.originFrame = frame
        self.kind = kind
        self.oldKind = kind
        self.imageName = imageName
        setImage(imageName)
        kindLabel?.text = kind
        
        self.imagesContent?.frame.origin.y = 44
        self.kindLabel?.frame.origin.y = CGRectGetMaxY(self.imagesContent!.frame) + 10
        self.deleteButton?.frame.origin.y = CGRectGetMaxY(self.kindLabel!.frame) + 10
        
        
        self.hidden = false
        self.bgView?.hidden = false
        self.closeButton?.hidden = false
//        self.addButton?.hidden = false
        
        
        UIView.animateWithDuration(0.25, animations: {
            self.frame = CGRect(x: 10, y: 30, width: CGRectGetWidth(UIScreen.mainScreen().bounds) - 20, height: CGRectGetHeight(UIScreen.mainScreen().bounds) - 60)
            self.addButton?.frame = CGRectMake(CGRectGetWidth(UIScreen.mainScreen().bounds) - 80, 10, 50, 30)
            self.backgroundColor = bgColor
            if (self.isFirst) {
                self.isFirst = false
                let windows = UIApplication.sharedApplication().windows.reverse()
                for (_, window) in windows.enumerate() {
                    if (window.windowLevel == UIWindowLevelNormal) {
                        window.addSubview(self.bgView!)
                        window.addSubview(self)
                        break
                    }
                }
            }
        }, completion:
            {_ in
                self.imagesContent?.hidden = false
                self.kindLabel?.hidden = false
                if (canDelete) {
                    self.deleteButton?.hidden = false
                }
        })
    }
    
    func doneClicked(sender: UIControlEvents) {
        kindLabel?.resignFirstResponder()
        UIView.animateWithDuration(0.3, animations: {
            self.imagesContent?.frame.origin.y = 44
            self.kindLabel?.frame.origin.y = CGRectGetMaxY(self.imagesContent!.frame) + 10
            self.deleteButton?.frame.origin.y = CGRectGetMaxY(self.kindLabel!.frame) + 10
            if (self.imageName != nil && self.imageName != "" && self.imageName != "plus" && self.trim(self.kindLabel!.text!) != "") {
                self.addButton?.hidden = false
            }
            }, completion: { _ in
                self.kindLabel?.addGestureRecognizer(self.kindLabelTap!)
        })
    }
    
    func trim(str: String) -> String {
        return str.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }

}
