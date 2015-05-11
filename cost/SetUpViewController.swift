//
//  SetUpViewController.swift
//  cost
//
//  Created by 郭振永 on 15/5/12.
//  Copyright (c) 2015年 guozy. All rights reserved.
//

import UIKit

class SetUpViewController: UIViewController {
    
    var contentView: UIView?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        view.layer.cornerRadius = 5
        view.backgroundColor = UIColor(red: 244 / 255, green: 111 / 255, blue: 102 / 255, alpha: 1)
        contentView = UIView(frame: view.frame)
        view.addSubview(contentView!)
        
        initTopBar()
    }
    
    override func viewWillAppear(animated: Bool) {
        contentView!.transform = CGAffineTransformMakeScale(0.9, 0.9)
        UIView.animateWithDuration(0.3, animations: {
            self.contentView!.transform = CGAffineTransformMakeScale(1, 1)
            }, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initTopBar() {
        let closeTap = UITapGestureRecognizer(target: self, action: "JustCloseSetUpView:")
        
        var closeButton = UILabel(frame: CGRectMake(10, 27, 30, 30))
        closeButton.userInteractionEnabled = true
        closeButton.text = "✕"
        closeButton.textColor = UIColor.whiteColor()
        closeButton.font = UIFont(name: "Avenir-Heavy", size: 28)!
        closeButton.addGestureRecognizer(closeTap)
        contentView!.addSubview(closeButton)
    }

    func JustCloseSetUpView(sender: UITapGestureRecognizer) {
        UIView.animateWithDuration(0.3, animations: {
            self.contentView!.alpha = 0
            self.contentView!.transform = CGAffineTransformMakeScale(0.9, 0.9)
            }, completion: {_ in
                self.performSegueWithIdentifier("closeSetUpView", sender: self)
        })
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
