//
//  SetUpViewController.swift
//  cost
//
//  Created by 郭振永 on 15/5/12.
//  Copyright (c) 2015年 guozy. All rights reserved.
//

import UIKit
import CoreData
import MessageUI

class SetUpViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    var contentView: UIView?
    var autoSyncTip: UILabel?
    var font: UIFont = UIFont(name: "Avenir", size: 18)!
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
//        view.backgroundColor = UIColor(red: 244 / 255, green: 111 / 255, blue: 102 / 255, alpha: 1)
        view.backgroundColor = theme.valueForKey(theTheme) as? UIColor
        contentView = UIView(frame: view.frame)
        view.addSubview(contentView!)
        
        initTopBar()
        initViews()
    }
    
    override func viewWillAppear(animated: Bool) {
        view.backgroundColor = theme.valueForKey(theTheme) as? UIColor
        contentView!.transform = CGAffineTransformMakeScale(0.9, 0.9)
        UIView.animateWithDuration(0.3, animations: {
            self.contentView!.transform = CGAffineTransformMakeScale(1, 1)
            }, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
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
    
    func initViews() {
        var width: CGFloat = view.frame.width / 2 - 10
        var height: CGFloat = 54
        var marginBetweenButton:CGFloat = 4
        
        let exportToExcelLabel = UILabel(frame: CGRectMake(0, 0, width * 2, height))
        exportToExcelLabel.text = "Export through Email"
        exportToExcelLabel.textColor = UIColor.whiteColor()
        exportToExcelLabel.font = font
        exportToExcelLabel.userInteractionEnabled = true
        let exportExcelTap = UITapGestureRecognizer(target: self, action: "exportExcel:")
        exportToExcelLabel.addGestureRecognizer(exportExcelTap)
        
        let exportToExcelView = UIView(frame: CGRectMake(10, 64 + marginBetweenButton, width * 2, height))
        exportToExcelView.addSubview(exportToExcelLabel)
        
        let suggestionToMeLabel = UILabel(frame: CGRectMake(0, 0, width * 2, height))
        suggestionToMeLabel.text = "Suggestions"
        suggestionToMeLabel.textColor = UIColor.whiteColor()
        suggestionToMeLabel.font = font
        suggestionToMeLabel.userInteractionEnabled = true
        let suggestionToMeTap = UITapGestureRecognizer(target: self, action: "suggestionToMe:")
        suggestionToMeLabel.addGestureRecognizer(suggestionToMeTap)
        
        let suggestionToMeView = UIView(frame: CGRectMake(10, 64 + height + marginBetweenButton * 2, width * 2, height))
        suggestionToMeView.addSubview(suggestionToMeLabel)
        
        let themeLabel = UILabel(frame: CGRectMake(10, 64 + height * 2 + marginBetweenButton * 3, width * 2, height))
        themeLabel.text = "Themes"
        themeLabel.textColor = UIColor.whiteColor()
        themeLabel.font = font
        themeLabel.userInteractionEnabled = true
        let themeTap = UITapGestureRecognizer(target: self, action: "showThemeView:")
        themeLabel.addGestureRecognizer(themeTap)
        
        contentView!.addSubview(exportToExcelView)
        contentView!.addSubview(suggestionToMeView)
        contentView!.addSubview(themeLabel)
    }
    
//MARK: action
    func JustCloseSetUpView(sender: UITapGestureRecognizer) {
        UIView.animateWithDuration(0.3, animations: {
            self.contentView!.alpha = 0
            self.contentView!.transform = CGAffineTransformMakeScale(0.9, 0.9)
            }, completion: {_ in
                self.performSegueWithIdentifier("closeSetUpView", sender: self)
        })
    }
    
    func showThemeView(sender: UITapGestureRecognizer) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("themeView") as! ThemeViewController
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func toggleAutoSync(sender: UITapGestureRecognizer) {
//        let view: UILabel = sender.view!
        if autoSyncTip!.text == "YES" {
            autoSyncTip?.text = "NO"
            println("open auto sync")
        } else {
            autoSyncTip?.text = "YES"
            println("close auto sync")
        }
    }
    
    func syncNow(sender: UITapGestureRecognizer) {
        
    }
    
    func exportExcel(sender: UITapGestureRecognizer) {
        let mailComposeViewController = configuredExportDataMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.presentViewController(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    func suggestionToMe(sender: UITapGestureRecognizer) {
        let mailComposeViewController = configuredSentToMeMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.presentViewController(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    
//MARK: for sent Email
    func configuredSentToMeMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setToRecipients(["hepeguo@gmail.com"])
        mailComposerVC.setSubject("Some suggestions for you")
        mailComposerVC.setMessageBody("Some suggestions...", isHTML: false)
        
        return mailComposerVC
    }
    
    func configuredExportDataMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setToRecipients([])
        mailComposerVC.setSubject("My cost data")
        mailComposerVC.setMessageBody("My cost data", isHTML: false)
        
        let data = compileDataToExcel()
        
        let fileManager = (NSFileManager.defaultManager())
        let directorys : [String]? = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory,NSSearchPathDomainMask.AllDomainsMask, true) as? [String]
        
        if ((directorys) != nil) {
            
            let directories:[String] = directorys!;
            let dictionary = directories[0];
            let plistfile = "cost-data.csv"
            let plistpath = dictionary.stringByAppendingPathComponent(plistfile);
            
            data.writeToFile(plistpath, atomically: true, encoding: NSUTF8StringEncoding, error: nil)
            var costData: NSData = NSData(contentsOfFile: plistpath)!
            mailComposerVC.addAttachmentData(costData, mimeType: "text/csv", fileName: "cost-data.csv")
        }
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    // MARK: MFMailComposeViewControllerDelegate
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        controller.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func compileDataToExcel() -> String {
        let items = getAllDataFromDatabase()
        var data = "Index,Price,Kind,Detail\n"
        if items != nil {
            for (index, item) in enumerate(items!) {
                data += "\(index),\(item.price),\(item.kind),\(item.detail)\n"
            }
        }
        return data
    }
    
//MARK: get data from database
    func getAllDataFromDatabase() -> [ItemModel]? {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName: "ItemModel")
        
        var error:NSError?
        
        fetchRequest.predicate = NSPredicate(format: "kill == false")
        let fetchResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as! [ItemModel]?
        return fetchResults
    }
}
