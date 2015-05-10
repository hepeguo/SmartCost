//
//  NewItemViewController.swift
//  $Mate
//
//  Created by 郭振永 on 15/3/15.
//  Copyright (c) 2015年 guozy. All rights reserved.
//

import UIKit

class NewItemViewController: UIViewController, NumberPadDelegate {
    
    lazy var item: Item = Item()
    var addButton: UILabel?
    var priceLabel: UILabel?
    var numberPad: NumberPad?
    var contentView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //prevent VerticalScroll
        self.automaticallyAdjustsScrollViewInsets = false
        view.layer.cornerRadius = 5
        view.backgroundColor = UIColor(red: 244 / 255, green: 111 / 255, blue: 102 / 255, alpha: 1)
        contentView = UIView(frame: view.frame)
        view.addSubview(contentView!)
        
        initTopBar()
        initFormViews()
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
        numberPad = NumberPad(frame: CGRectMake(0, view.frame.height - 300, view.frame.width, 300))
        numberPad?.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
        numberPad?.delegate = self
        contentView!.addSubview(numberPad!)
        
        var priceLabelBorder = UILabel(frame: CGRectMake(10, 84, view.frame.width - 20, 44))
        priceLabelBorder.userInteractionEnabled = true
        priceLabelBorder.layer.borderWidth = 2
        priceLabelBorder.layer.borderColor = UIColor.whiteColor().CGColor
        
        priceLabel = UILabel(frame: CGRectMake(5, 0, view.frame.width - 30, 44))
        if item.price != 0.0 {
            priceLabel?.text = "\(item.price)"
            addButton?.text = "SAVE"
            addButton?.alpha = 1
            numberPad?.frame.origin.y = view.frame.height
            numberPad?.hidden = true
        } else {
            priceLabel?.text = "0"
        }
        priceLabel?.font = UIFont(name: "Avenir-Heavy", size: 30)!
        priceLabel?.textColor = UIColor.whiteColor()
        priceLabel?.textAlignment = .Right
        priceLabel?.userInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: "showNumberPad:")
        priceLabel?.addGestureRecognizer(tap)
        
        priceLabelBorder.addSubview(priceLabel!)
        contentView!.addSubview(priceLabelBorder)
    }
    
    func JustCloseAddItemView(sender: UITapGestureRecognizer) {
        UIView.animateWithDuration(0.3, animations: {
            self.contentView!.alpha = 0
            self.contentView!.transform = CGAffineTransformMakeScale(0.9, 0.9)
            }, completion: {_ in
                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("MainView") as! MainViewController
                self.presentViewController(vc, animated: false, completion: nil)
        })
    }
    
    func closeAddItemViewWithNewer(sender: UITapGestureRecognizer) {
        let price = priceLabel!.text!
        item.price = (price as NSString).floatValue
        item.detail = "super man"
        item.kind = "dinner"
        item.kill = false
        
        UIView.animateWithDuration(0.3, animations: {
            self.contentView!.alpha = 0
            self.contentView!.transform = CGAffineTransformMakeScale(0.9, 0.9)
            }, completion: {_ in
                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("MainView") as! MainViewController
                self.presentViewController(vc, animated: false, completion: {_ in
                    vc.newItemFromAddView(self.item)
                })
        })
    }
    
    func showNumberPad(sender: UITapGestureRecognizer) {
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
}
