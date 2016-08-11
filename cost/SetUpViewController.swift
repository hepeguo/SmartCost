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
                returnValue = "blue"
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
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func initTopBar() {
        let closeTap = UITapGestureRecognizer(target: self, action: #selector(SetUpViewController.JustCloseSetUpView(_:)))
        
        let closeButton = UILabel(frame: CGRectMake(10, 27, 30, 30))
        closeButton.userInteractionEnabled = true
        closeButton.text = "✕"
        closeButton.textColor = UIColor.whiteColor()
        closeButton.font = UIFont(name: "Avenir-Heavy", size: 28)!
        closeButton.addGestureRecognizer(closeTap)
        contentView!.addSubview(closeButton)
    }
    
    func initViews() {
        let width: CGFloat = view.frame.width / 2 - 10
        let height: CGFloat = 54
        let marginBetweenButton:CGFloat = 4
        
        let exportToExcelLabel = UILabel(frame: CGRectMake(0, 0, width * 2, height))
        exportToExcelLabel.text = "Export through Email"
        exportToExcelLabel.textColor = UIColor.whiteColor()
        exportToExcelLabel.font = font
        exportToExcelLabel.userInteractionEnabled = true
        let exportExcelTap = UITapGestureRecognizer(target: self, action: #selector(SetUpViewController.exportExcel(_:)))
        exportToExcelLabel.addGestureRecognizer(exportExcelTap)
        
        let exportToExcelView = UIView(frame: CGRectMake(10, 64 + marginBetweenButton, width * 2, height))
        exportToExcelView.addSubview(exportToExcelLabel)
        
        let suggestionToMeLabel = UILabel(frame: CGRectMake(0, 0, width * 2, height))
        suggestionToMeLabel.text = "Suggestions"
        suggestionToMeLabel.textColor = UIColor.whiteColor()
        suggestionToMeLabel.font = font
        suggestionToMeLabel.userInteractionEnabled = true
        let suggestionToMeTap = UITapGestureRecognizer(target: self, action: #selector(SetUpViewController.suggestionToMe(_:)))
        suggestionToMeLabel.addGestureRecognizer(suggestionToMeTap)
        
        let suggestionToMeView = UIView(frame: CGRectMake(10, 64 + height + marginBetweenButton * 2, width * 2, height))
        suggestionToMeView.addSubview(suggestionToMeLabel)
        
        let themeLabel = UILabel(frame: CGRectMake(10, 64 + height * 2 + marginBetweenButton * 3, width * 2, height))
        themeLabel.text = "Themes"
        themeLabel.textColor = UIColor.whiteColor()
        themeLabel.font = font
        themeLabel.userInteractionEnabled = true
        let themeTap = UITapGestureRecognizer(target: self, action: #selector(SetUpViewController.showThemeView(_:)))
        themeLabel.addGestureRecognizer(themeTap)
        
        let categoriesLabel = UILabel(frame: CGRectMake(10, 64 + height * 3 + marginBetweenButton * 4, width * 2, height))
        categoriesLabel.text = "Categories"
        categoriesLabel.textColor = UIColor.whiteColor()
        categoriesLabel.font = font
        categoriesLabel.userInteractionEnabled = true
        let categoriesTap = UITapGestureRecognizer(target: self, action: #selector(SetUpViewController.showCatagoriesView(_:)))
        categoriesLabel.addGestureRecognizer(categoriesTap)
        
        contentView!.addSubview(exportToExcelView)
        contentView!.addSubview(suggestionToMeView)
        contentView!.addSubview(themeLabel)
        contentView!.addSubview(categoriesLabel)
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
    
    func showCatagoriesView(sender: UITapGestureRecognizer) {
        let vc = CatagoriesViewController()
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func toggleAutoSync(sender: UITapGestureRecognizer) {
        if autoSyncTip!.text == "YES" {
            autoSyncTip?.text = "NO"
            print("open auto sync")
        } else {
            autoSyncTip?.text = "YES"
            print("close auto sync")
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
        
        _ = (NSFileManager.defaultManager())
        let directorys : [String]? = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory,NSSearchPathDomainMask.AllDomainsMask, true) as [String]
        
        if ((directorys) != nil) {
            
            let directories:[String] = directorys!;
            let dictionary = directories[0];
            let plistfile = "/cost-data.csv"
            let plistpath = dictionary.stringByAppendingString(plistfile)
            
            do {
                try data.writeToFile(plistpath, atomically: true, encoding: NSUTF8StringEncoding)
            } catch let error as NSError  {
                print(error)
            }
            let costData: NSData = NSData(contentsOfFile: plistpath)!
            mailComposerVC.addAttachmentData(costData, mimeType: "text/csv", fileName: "cost-data.csv")
        }
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    // MARK: MFMailComposeViewControllerDelegate
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func compileDataToExcel() -> String {
        let items = getAllDataFromDatabase()
        var data = "Index,Price,Kind,Detail,Time\n"
        if items != nil {
            for (index, item) in items!.enumerate() {
                data += "\(index),\(String(format: "%.2f", Float(item.price))),\(item.kind),\(item.detail),\(item.year)-\(item.month)-\(item.day) \(item.addTime)\n"
            }
        }
        return data
    }
    
//MARK: get data from database
    func getAllDataFromDatabase() -> [ItemModel]? {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName: "ItemModel")
        
        fetchRequest.predicate = NSPredicate(format: "kill == false")
        
        var fetchResults: [ItemModel]?
        do {
            fetchResults = try managedContext.executeFetchRequest(fetchRequest) as? [ItemModel]
        } catch let error as NSError {
            print(error)
        }
        return fetchResults
    }
}
