//
//  NewItemViewController.swift
//  $Mate
//
//  Created by 郭振永 on 15/3/15.
//  Copyright (c) 2015年 guozy. All rights reserved.
//

import UIKit

class NewItemViewController: UIViewController, NumberPadDelegate, UITextViewDelegate {
    
    lazy var item: Item = Item()
    var addButton: UILabel?
    var priceLabel: UILabel?
    var detailTextView: UITextView?
    var numberPad: NumberPad?
    var contentView: UIView?
    var kind = [
        "en": ["Film", "Food", "Snacks", "Clothing", "Shopping", "Gifts", "Home", "Study", "Traffic", "Fun", "Net Bill", "Visa", "Investment", "Medical", "Other"],
        "ch": ["电影", "餐饮", "零食", "服饰", "购物", "礼物", "居家", "学习", "交通", "娱乐", "通信", "信用卡", "理财", "医疗", "其他"]
    ]
    var kindViews: [KindItemView] = [KindItemView]()
    var kindViewsPageView: PageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //prevent VerticalScroll
        self.automaticallyAdjustsScrollViewInsets = false
        view.layer.cornerRadius = 5
        view.backgroundColor = UIColor(red: 244 / 255, green: 111 / 255, blue: 102 / 255, alpha: 1)
        contentView = UIView(frame: view.frame)
        view.addSubview(contentView!)
        
        let language = NSBundle.mainBundle().preferredLocalizations.first as! String
        println(language)
//        println(kind[language as String])
        
        initTopBar()
        initKindView()
        initFormViews()
        
        if item.id != "" {
            setUpViews()
        }
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
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func initTopBar() {
        let closeTap = UITapGestureRecognizer(target: self, action: "JustCloseAddItemView:")
        
        var closeButton = UILabel(frame: CGRectMake(10, 27, 30, 30))
        closeButton.userInteractionEnabled = true
        closeButton.text = "✕"
        closeButton.textColor = UIColor.whiteColor()
        closeButton.font = UIFont(name: "Avenir-Heavy", size: 28)!
        closeButton.addGestureRecognizer(closeTap)
        contentView!.addSubview(closeButton)
        
        let addTap = UITapGestureRecognizer(target: self, action: "closeAddItemViewWithNewer:")
        addButton = UILabel(frame: CGRectMake(view.frame.width - 60, 27, 50, 30))
        addButton?.userInteractionEnabled = true
        addButton?.text = "ADD"
        addButton?.textAlignment = .Right
        addButton?.textColor = UIColor.whiteColor()
        addButton?.font = UIFont(name: "Avenir-Heavy", size: 18)!
        addButton?.addGestureRecognizer(addTap)
        addButton?.alpha = 0
        contentView!.addSubview(addButton!)
    }
    
    func initFormViews() {
        var priceLabelBorder = UILabel(frame: CGRectMake(10, 84, view.frame.width - 20, 44))
        priceLabelBorder.userInteractionEnabled = true
        priceLabelBorder.layer.borderWidth = 2
        priceLabelBorder.layer.borderColor = UIColor.whiteColor().CGColor
        
        priceLabel = UILabel(frame: CGRectMake(5, 0, view.frame.width - 30, 44))
        priceLabel?.text = "0"
        priceLabel?.font = UIFont(name: "Avenir-Heavy", size: 30)!
        priceLabel?.textColor = UIColor.whiteColor()
        priceLabel?.textAlignment = .Right
        priceLabel?.userInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: "showNumberPad:")
        priceLabel?.addGestureRecognizer(tap)
        
        priceLabelBorder.addSubview(priceLabel!)
        contentView!.addSubview(priceLabelBorder)
        
        let detailTextViewBg = UILabel(frame: CGRectMake(10, 140 + kindViewsPageView!.frame.height, view.frame.width - 20, 88))
        detailTextViewBg.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
        detailTextViewBg.userInteractionEnabled = true
        
        detailTextView = UITextView(frame: CGRectMake(5, 0, view.frame.width - 30, 88))
        detailTextView?.textColor = UIColor.whiteColor()
        detailTextView?.backgroundColor = UIColor.clearColor()
        detailTextView?.font = UIFont(name: "Avenir-Heavy", size: 18)!
        detailTextView?.userInteractionEnabled = true
        detailTextView?.returnKeyType = .Done
//        detailTextView?.autocapitalizationType = .None
//        detailTextView?.autocorrectionType = .No
//        detailTextView?.spellCheckingType = .No
        detailTextView?.delegate = self
        let detailTap = UITapGestureRecognizer(target: self, action: "detailTapped:")
        detailTextView?.addGestureRecognizer(detailTap)
        detailTextViewBg.addSubview(detailTextView!)
        contentView?.addSubview(detailTextViewBg)
        
        numberPad = NumberPad(frame: CGRectMake(0, view.frame.height - 300, view.frame.width, 300))
        numberPad?.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
        numberPad?.layer.zPosition = 2
        numberPad?.delegate = self
        contentView!.addSubview(numberPad!)
    }
    
    func initKindView() {
        let width = view.frame.width / 5
        let height = width - 15
        
        var kindViewContentFirst = UIView(frame: CGRectMake(0, 0, view.frame.width, height * CGFloat(2)))
        var kindViewContentSecond = UIView(frame: CGRectMake(view.frame.width, 0, view.frame.width, height * CGFloat(2)))
        
        for (index, item) in enumerate(kind["ch"]!) {
            var rect: CGRect = CGRectZero
            if index <= 9 {
                rect = CGRectMake(CGFloat(index % 5) * width, CGFloat(index / 5) * height, width, height)
            } else {
                let newIndex = index - 10
                rect = CGRectMake(CGFloat(newIndex % 5) * width, CGFloat(newIndex / 5) * height, width, height)
            }
            
            let itemView = KindItemView(frame: rect, kind: item)
            
            let tapKind = UITapGestureRecognizer(target: self, action: "selectKind:")
            itemView.addGestureRecognizer(tapKind)
            
            kindViews.append(itemView)
            if index <= 9 {
                kindViewContentFirst.addSubview(itemView)
            } else {
                kindViewContentSecond.addSubview(itemView)
            }
        }
        var views = [kindViewContentFirst, kindViewContentSecond]
        kindViewsPageView = PageView(frame: CGRectMake(0, 135, view.frame.width, kindViewContentSecond.frame.height + CGFloat(20) ), views: views)
        contentView!.addSubview(kindViewsPageView!)
    }
    
    func setUpViews() {
        priceLabel?.text = "\(item.price)"
        addButton?.text = "SAVE"
        addButton?.alpha = 1
        numberPad?.frame.origin.y = view.frame.height
        numberPad?.hidden = true
        detailTextView?.text = item.detail
        for (index, kindView) in enumerate(kindViews) {
            if kindView.kind == item.kind {
                if index >= 10 {
                    kindViewsPageView?.scrollTo(CGPointMake(view.frame.width, 0))
                }
                kindView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
            }
        }
    }
    
//MARK: actions
    
    func JustCloseAddItemView(sender: UITapGestureRecognizer) {
        detailTextView?.resignFirstResponder()
        UIView.animateWithDuration(0.3, animations: {
            self.contentView!.alpha = 0
            self.contentView!.transform = CGAffineTransformMakeScale(0.9, 0.9)
            }, completion: {_ in
                self.performSegueWithIdentifier("closeNewItemView", sender: self)
        })
    }
    
    func closeAddItemViewWithNewer(sender: UITapGestureRecognizer) {
        detailTextView?.resignFirstResponder()
        let price = priceLabel!.text!
        item.price = (price as NSString).floatValue
        item.detail = detailTextView!.text
        item.kill = false
        
        UIView.animateWithDuration(0.3, animations: {
            self.contentView!.alpha = 0
            self.contentView!.transform = CGAffineTransformMakeScale(0.9, 0.9)
            }, completion: {_ in
                self.performSegueWithIdentifier("closeNewItemView", sender: self)
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if item.price != 0 {
            let mainViewController = segue.destinationViewController as! MainViewController
            mainViewController.newItemFromAddView(self.item)
        }
    }
    
    func showNumberPad(sender: UITapGestureRecognizer) {
        detailTextView?.resignFirstResponder()
        if numberPad?.hidden == true {
            numberPad?.hidden = false
            UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.55, initialSpringVelocity: 0.1, options: UIViewAnimationOptions.BeginFromCurrentState, animations: {
                numberPad?.frame.origin.y = view.frame.height - 300
                }, completion: nil)
        }
    }
    
    func tappedNumber(text: String) {
        var price = "";
        if priceLabel!.text != nil && priceLabel!.text != "0" {
            price = priceLabel!.text!
        }
        switch text {
            case "0": priceLabel!.text = price + text
            case "1": priceLabel!.text = price + text
            case "2": priceLabel!.text = price + text
            case "3": priceLabel!.text = price + text
            case "4": priceLabel!.text = price + text
            case "5": priceLabel!.text = price + text
            case "6": priceLabel!.text = price + text
            case "7": priceLabel!.text = price + text
            case "8": priceLabel!.text = price + text
            case "9": priceLabel!.text = price + text
            case "C": priceLabel!.text = "0"
            case ".":
                let NSPrice = price as NSString
                if [NSPrice .rangeOfString(".")].first?.location == NSNotFound {
                    if price.isEmpty {
                        priceLabel!.text = "0" + text
                    } else {
                        priceLabel!.text = price + text
                    }
                }
            case "⌫":
                if price == "0" || price == "" {
                    return
                }
                let index = advance(price.endIndex, -1);
                let newPrice = price.substringToIndex(index)
                if newPrice.isEmpty {
                    priceLabel!.text = "0"
                } else {
                    priceLabel!.text = newPrice
                }
            case "OK":
                UIView.animateWithDuration(0.3, animations: {
                    numberPad?.frame.origin.y = view.frame.height
                    }, completion: { _ in
                     numberPad?.hidden = true
                })
            default: return
        }
        if priceLabel?.text != "0" && priceLabel?.text != "" {
            if addButton?.alpha == 1 {
                return
            }
            UIView.animateWithDuration(0.3, animations: {
                addButton?.alpha = 1
            }, completion: nil)
        } else {
            if addButton?.alpha == 0 {
                return
            }
            UIView.animateWithDuration(0.3, animations: {
                addButton?.alpha = 0
                }, completion: nil)
        }
    }
    
    func selectKind(sender: UITapGestureRecognizer) {
        detailTextView?.resignFirstResponder()
        let view = sender.view as! KindItemView
        for (index, kindView) in enumerate(kindViews) {
            kindView.backgroundColor = UIColor.clearColor()
        }
        view.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
        item.kind = view.kind!
        println(view.kind)
    }
    
    func detailTapped(sender: UITapGestureRecognizer) {
        UIView.animateWithDuration(0.3, animations: {
            numberPad?.frame.origin.y = view.frame.height
            }, completion: { _ in
                self.numberPad?.hidden = true
                self.detailTextView?.becomeFirstResponder()
        })
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false;
        }
        return true;
    }
}
