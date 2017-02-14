//
//  CatagoriesEditView.swift
//  cost
//
//  Created by 郭振永 on 15/12/6.
//  Copyright © 2015年 guozy. All rights reserved.
//

import UIKit

protocol CatagoriesEditDelegate {
    func endCatagoriesEdit(_ kind: String, oldKind: String, imageName: String, delete: Bool)
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
    
    var originFrame: CGRect = CGRect.zero
    
    var isFirst: Bool = true
    
    var imagesContent: UIScrollView?
    var kindViews: [KindItemView] = [KindItemView]()
    
    var kindLabelTap: UITapGestureRecognizer?
    
    var delegate:CatagoriesEditDelegate?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = 5
        bgView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
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
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        let margin: CGFloat = 10
        let numberInline: CGFloat = 4
        let width: CGFloat = (screenWidth - margin * 4) / numberInline
        let height: CGFloat = width
        
        imagesContent = UIScrollView(frame: CGRect(x: 10, y: 44, width: screenWidth - 40, height: screenHeight - 232))
        imagesContent?.contentSize = CGSize(width: screenWidth - 40, height: height * CGFloat(allImage.count / Int(numberInline) + 1))
        imagesContent?.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        imagesContent?.showsHorizontalScrollIndicator = false
        imagesContent?.showsVerticalScrollIndicator = false
        imagesContent?.scrollsToTop = false
        imagesContent?.isDirectionalLockEnabled = true
        imagesContent?.isHidden = true
        
        self.addSubview(imagesContent!)
        
        for (index, item) in allImage.enumerated() {
            var rect: CGRect = CGRect.zero
            rect = CGRect(x: CGFloat(index % Int(numberInline)) * width, y: CGFloat(index / Int(numberInline)) * height, width: width, height: height)
            
            let itemView = KindItemView(frame: rect, imageName: item)
            
            let tapKind = UITapGestureRecognizer(target: self, action: #selector(CatagoriesEditView.selectImage(_:)))
            itemView.addGestureRecognizer(tapKind)
            
            kindViews.append(itemView)
            
            imagesContent?.addSubview(itemView)
        }
        self.addSubview(imagesContent!)
    }
    
    func initView() {
        kindLabel = UITextField(frame: CGRect(x: 10, y: imagesContent!.frame.maxY + 10, width: imagesContent!.frame.width, height: 44))
        kindLabel?.layer.borderWidth = 2
        kindLabel?.layer.borderColor = UIColor.white.cgColor
        kindLabel?.font = UIFont(name: "Avenir-Heavy", size: 18)!
        kindLabel?.isUserInteractionEnabled = true
        kindLabel?.returnKeyType = .done
        kindLabel?.textColor = UIColor.white
        kindLabel?.addTarget(self, action: #selector(CatagoriesEditView.doneClicked(_:)), for: UIControlEvents.editingDidEndOnExit)
        kindLabel?.addTarget(self, action: #selector(CatagoriesEditView.kindLabelTapped(_:)), for: .editingDidBegin)
        kindLabelTap = UITapGestureRecognizer(target: self, action: #selector(CatagoriesEditView.kindLabelTapped(_:)))
        kindLabel?.addGestureRecognizer(kindLabelTap!)
        
        let spacerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height:10))
        kindLabel?.leftViewMode = .always
        kindLabel?.leftView = spacerView
        self.kindLabel?.isHidden = true
        
        self.addSubview(kindLabel!)
        
        deleteButton = UILabel(frame: CGRect(x: 10, y: kindLabel!.frame.maxY + 10, width: imagesContent!.frame.width, height: 44))
        deleteButton?.text = "DELETE"
        deleteButton?.textAlignment = .center
        deleteButton?.textColor = UIColor.white
        deleteButton?.font = UIFont(name: "Avenir-Heavy", size: 18)!
        deleteButton?.isUserInteractionEnabled = true
        deleteButton?.isHidden = true
        let deleteKindLabelTap = UITapGestureRecognizer(target: self, action: #selector(CatagoriesEditView.deleteKind(_:)))
        deleteButton?.addGestureRecognizer(deleteKindLabelTap)
        
        self.addSubview(deleteButton!)
    }
    
    func initTopBar() {
        let closeTap = UITapGestureRecognizer(target: self, action: #selector(CatagoriesEditView.JustCloseEditView(_:)))
        
        closeButton = UILabel(frame: CGRect(x: 10, y: 10, width: 30, height: 30))
        closeButton?.isUserInteractionEnabled = true
        closeButton?.text = "✕"
        closeButton?.textColor = UIColor.white
        closeButton?.font = UIFont(name: "Avenir-Heavy", size: 28)!
        closeButton?.addGestureRecognizer(closeTap)
        self.addSubview(closeButton!)
        
        let addTap = UITapGestureRecognizer(target: self, action: #selector(CatagoriesEditView.closeEditWithNewer(_:)))
        addButton = UILabel(frame: CGRect.zero)
        addButton?.isUserInteractionEnabled = true
        addButton?.text = "SAVE"
        addButton?.textAlignment = .right
        addButton?.textColor = UIColor.white
        addButton?.font = UIFont(name: "Avenir-Heavy", size: 18)!
        addButton?.addGestureRecognizer(addTap)
        self.addSubview(addButton!)
    }
    
    func selectImage(_ sender: UITapGestureRecognizer) {
        let view = sender.view as! KindItemView
        for (_, kindView) in kindViews.enumerated() {
            kindView.backgroundColor = UIColor.clear
        }
        view.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
        self.imageName = view.imageName!
        if trim(kindLabel!.text!) != "" {
            addButton?.isHidden = false
        }
    }
    
    func setImage(_ imageName: String) {
        var has = false
        for (_, kindView) in kindViews.enumerated() {
            if kindView.imageName == imageName {
                kindView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
                has = true
            } else {
                kindView.backgroundColor = UIColor.clear
            }
        }
        if !has {
            addButton?.isHidden = true
        }
    }
    
    func kindLabelTapped(_ sender: UIGestureRecognizer) {
        UIView.animate(withDuration: 0.3, animations: {
            self.imagesContent?.frame.origin.y = -(self.imagesContent!.frame.height + (self.kindLabel?.frame.height)! + 44)
            self.kindLabel?.frame.origin.y = 44
            self.deleteButton?.frame.origin.y = self.kindLabel!.frame.maxY + 10
            self.addButton?.isHidden = true
            }, completion: { _ in
                self.kindLabel?.removeGestureRecognizer(self.kindLabelTap!)
                self.kindLabel?.becomeFirstResponder()
        })
    }
    
    func JustCloseEditView(_ sender: UITapGestureRecognizer) {
        imagesContent?.isHidden = true
        self.kindLabel?.isHidden = true
        self.deleteButton?.isHidden = true
        self.kindLabel?.resignFirstResponder()
        UIView.animate(withDuration: 0.25, animations: {
            self.frame = self.originFrame
            self.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.75)
            self.closeButton?.isHidden = true
            self.bgView?.isHidden = true
            self.addButton?.frame = CGRect.zero
            self.addButton?.isHidden = true
        }, completion: { _ in
            self.isHidden = true
        })
    }
    
    func closeEditWithNewer(_ sender: UITapGestureRecognizer) {
        self.kindLabel?.resignFirstResponder()
        if kindLabel?.text != nil {
            imagesContent?.isHidden = true
            self.kindLabel?.isHidden = true
            self.deleteButton?.isHidden = true
            UIView.animate(withDuration: 0.25, animations: {
                self.frame = self.originFrame
                self.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.75)
                self.closeButton?.isHidden = true
                self.bgView?.isHidden = true
                self.addButton?.frame = CGRect.zero
                self.addButton?.isHidden = true
                }, completion: { _ in
                    self.isHidden = true
                    self.delegate?.endCatagoriesEdit((self.kindLabel?.text)!, oldKind: self.oldKind, imageName: self.imageName!, delete: false)
            })
        }
    }
    
    func deleteKind(_ sender: UITapGestureRecognizer) {
        imagesContent?.isHidden = true
        self.kindLabel?.isHidden = true
        self.deleteButton?.isHidden = true
        UIView.animate(withDuration: 0.25, animations: {
            self.frame = self.originFrame
            self.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.75)
            self.closeButton?.isHidden = true
            self.bgView?.isHidden = true
            self.addButton?.frame = CGRect.zero
            self.addButton?.isHidden = true
            }, completion: { _ in
                self.isHidden = true
                self.delegate?.endCatagoriesEdit((self.kindLabel?.text)!, oldKind: self.oldKind, imageName: self.imageName!, delete: true)
        })
    }
    
    
    func show(_ frame: CGRect, kind: String, imageName: String, bgColor: UIColor, canDelete: Bool) {
        self.frame = frame
        self.originFrame = frame
        self.kind = kind
        self.oldKind = kind
        self.imageName = imageName
        setImage(imageName)
        kindLabel?.text = kind
        
        self.imagesContent?.frame.origin.y = 44
        self.kindLabel?.frame.origin.y = self.imagesContent!.frame.maxY + 10
        self.deleteButton?.frame.origin.y = self.kindLabel!.frame.maxY + 10
        
        
        self.isHidden = false
        self.bgView?.isHidden = false
        self.closeButton?.isHidden = false
//        self.addButton?.hidden = false
        
        
        UIView.animate(withDuration: 0.25, animations: {
            self.frame = CGRect(x: 10, y: 30, width: UIScreen.main.bounds.width - 20, height: UIScreen.main.bounds.height - 60)
            self.addButton?.frame = CGRect(x: UIScreen.main.bounds.width - 80, y: 10, width: 50, height: 30)
            self.backgroundColor = bgColor
            if (self.isFirst) {
                self.isFirst = false
                let windows = UIApplication.shared.windows.reversed()
                for (_, window) in windows.enumerated() {
                    if (window.windowLevel == UIWindowLevelNormal) {
                        window.addSubview(self.bgView!)
                        window.addSubview(self)
                        break
                    }
                }
            }
        }, completion:
            {_ in
                self.imagesContent?.isHidden = false
                self.kindLabel?.isHidden = false
                if (canDelete) {
                    self.deleteButton?.isHidden = false
                }
        })
    }
    
    func doneClicked(_ sender: UIControlEvents) {
        kindLabel?.resignFirstResponder()
        UIView.animate(withDuration: 0.3, animations: {
            self.imagesContent?.frame.origin.y = 44
            self.kindLabel?.frame.origin.y = self.imagesContent!.frame.maxY + 10
            self.deleteButton?.frame.origin.y = self.kindLabel!.frame.maxY + 10
            if (self.imageName != nil && self.imageName != "" && self.imageName != "plus" && self.trim(self.kindLabel!.text!) != "") {
                self.addButton?.isHidden = false
            }
            }, completion: { _ in
                self.kindLabel?.addGestureRecognizer(self.kindLabelTap!)
        })
    }
    
    func trim(_ str: String) -> String {
        return str.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }

}
