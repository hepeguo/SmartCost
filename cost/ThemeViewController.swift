//
//  ThemeViewController.swift
//  cost
//
//  Created by 郭振永 on 15/6/27.
//  Copyright (c) 2015年 guozy. All rights reserved.
//

import UIKit

class ThemeViewController: UIViewController {
    
    var contentView: UIView?
    var themes: [String] = ["origin", "blue", "orange", "green", "red", "purple", "pink", "lightGreen", "lightBlue", "gray"]
    var themeViews: [ThemeView] = []
    let theme = Theme()
    var theTheme: String {
        get {
            var returnValue: String? = NSUserDefaults.standardUserDefaults().objectForKey("theme") as? String
            if returnValue == nil
            {
                returnValue = "origin"
            }
            return returnValue!
        }
        set (newValue) {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "theme")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        view.layer.cornerRadius = 5
        let themeColor = theme.valueForKey(theTheme) as? UIColor
        view.backgroundColor = themeColor?.colorWithAlphaComponent(0.9)
        contentView = UIView(frame: view.frame)
        view.addSubview(contentView!)
        
        initTopBar()
        initViews()
        updateTheme()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func updateTheme() {
        for var i = 0; i < themeViews.count; i++ {
            if theTheme == themeViews[i].name {
                themeViews[i].addBorder()
            } else {
                themeViews[i].removeBorder()
            }
        }
    }

    func initTopBar() {
        let closeTap = UITapGestureRecognizer(target: self, action: "JustCloseThemeView:")
        
        var closeButton = UILabel(frame: CGRectMake(10, 27, 30, 30))
        closeButton.userInteractionEnabled = true
        closeButton.text = "✕"
        closeButton.textColor = UIColor.whiteColor()
        closeButton.font = UIFont(name: "Avenir-Heavy", size: 28)!
        closeButton.addGestureRecognizer(closeTap)
        contentView!.addSubview(closeButton)
    }
    
    func initViews() {
        let margin: CGFloat = 10
        let width: CGFloat = (view.frame.width - margin * 4) / 2
        let height: CGFloat = width / 1.5
        var themeContent = UIScrollView(frame: CGRectMake(0, 64, view.frame.width, view.frame.height - 64))
        themeContent.contentSize = CGSizeMake(view.frame.width, (height + margin * 2) * 5)
        themeContent.setContentOffset(CGPointMake(0, 0), animated: false)
        themeContent.showsHorizontalScrollIndicator = false
        themeContent.showsVerticalScrollIndicator = false
        themeContent.scrollsToTop = false
        themeContent.directionalLockEnabled = true
        
        contentView!.addSubview(themeContent)
        
        for (index, color) in enumerate(themes) {
            var x: CGFloat = margin
            if index % 2 == 1 {
                x = margin * 3 + width
            }
            let rect = CGRectMake(x, CGFloat(index / 2) * (height + margin), width, height)
            let view = ThemeView(frame: rect, name: color, color: theme.valueForKey(color) as! UIColor)
            let selectTap = UITapGestureRecognizer(target: self, action: "selectTheme:")
            view.addGestureRecognizer(selectTap)
            themeViews.append(view)
            themeContent.addSubview(view)
        }
    }
    
    func selectTheme(sender: UITapGestureRecognizer) {
        for var i = 0; i < themeViews.count; i++ {
            themeViews[i].removeBorder()
        }
        let themeView: ThemeView = sender.view as! ThemeView
        themeView.addBorder()
        
        UIView.animateWithDuration(0.3, animations: {
            self.view.backgroundColor = themeView.color.colorWithAlphaComponent(0.9)
            }, completion: nil)
        
        theTheme = themeView.name
    }
    
    func JustCloseThemeView(sender: UITapGestureRecognizer) {
        UIView.animateWithDuration(0.3, animations: {
            self.contentView!.alpha = 0
            self.contentView!.transform = CGAffineTransformMakeScale(0.9, 0.9)
            }, completion: {_ in
                self.dismissViewControllerAnimated(false, completion: nil)
        })
    }
}
