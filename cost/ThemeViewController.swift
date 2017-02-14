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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        view.layer.cornerRadius = 5
        let themeColor = theme.value(forKey: theTheme) as? UIColor
        view.backgroundColor = themeColor?.withAlphaComponent(0.9)
        contentView = UIView(frame: view.frame)
        view.addSubview(contentView!)
        
        initTopBar()
        initViews()
        updateTheme()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    func updateTheme() {
        for i in 0 ..< themeViews.count {
            if theTheme == themeViews[i].name {
                themeViews[i].addBorder()
            } else {
                themeViews[i].removeBorder()
            }
        }
    }

    func initTopBar() {
        let closeTap = UITapGestureRecognizer(target: self, action: #selector(ThemeViewController.JustCloseThemeView(_:)))
        
        let closeButton = UILabel(frame: CGRect(x: 10, y: 27, width: 30, height: 30))
        closeButton.isUserInteractionEnabled = true
        closeButton.text = "✕"
        closeButton.textColor = UIColor.white
        closeButton.font = UIFont(name: "Avenir-Heavy", size: 28)!
        closeButton.addGestureRecognizer(closeTap)
        contentView!.addSubview(closeButton)
    }
    
    func initViews() {
        let margin: CGFloat = 10
        let width: CGFloat = (view.frame.width - margin * 4) / 2
        let height: CGFloat = width / 1.5
        let themeContent = UIScrollView(frame: CGRect(x: 0, y: 64, width: view.frame.width, height: view.frame.height - 64))
        themeContent.contentSize = CGSize(width: view.frame.width, height: (height + margin * 2) * 5)
        themeContent.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        themeContent.showsHorizontalScrollIndicator = false
        themeContent.showsVerticalScrollIndicator = false
        themeContent.scrollsToTop = false
        themeContent.isDirectionalLockEnabled = true
        
        contentView!.addSubview(themeContent)
        
        for (index, color) in themes.enumerated() {
            var x: CGFloat = margin
            if index % 2 == 1 {
                x = margin * 3 + width
            }
            let rect = CGRect(x: x, y: CGFloat(index / 2) * (height + margin), width: width, height: height)
            let view = ThemeView(frame: rect, name: color, color: theme.value(forKey: color) as! UIColor)
            let selectTap = UITapGestureRecognizer(target: self, action: #selector(ThemeViewController.selectTheme(_:)))
            view.addGestureRecognizer(selectTap)
            themeViews.append(view)
            themeContent.addSubview(view)
        }
    }
    
    func selectTheme(_ sender: UITapGestureRecognizer) {
        for i in 0 ..< themeViews.count {
            themeViews[i].removeBorder()
        }
        let themeView: ThemeView = sender.view as! ThemeView
        themeView.addBorder()
        
        UIView.animate(withDuration: 0.3, animations: {
            self.view.backgroundColor = themeView.color.withAlphaComponent(0.9)
            }, completion: nil)
        
        theTheme = themeView.name
    }
    
    func JustCloseThemeView(_ sender: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.3, animations: {
            self.contentView!.alpha = 0
            self.contentView!.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }, completion: {_ in
                self.dismiss(animated: false, completion: nil)
        })
    }
}
