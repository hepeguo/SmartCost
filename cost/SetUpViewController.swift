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
        view.backgroundColor = theme.value(forKey: theTheme) as? UIColor
        contentView = UIView(frame: view.frame)
        view.addSubview(contentView!)
        
        initTopBar()
        initViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        view.backgroundColor = theme.value(forKey: theTheme) as? UIColor
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
    
    func initTopBar() {
        let closeTap = UITapGestureRecognizer(target: self, action: #selector(SetUpViewController.JustCloseSetUpView(_:)))
        
        let closeButton = UILabel(frame: CGRect(x: 10, y: 27, width: 30, height: 30))
        closeButton.isUserInteractionEnabled = true
        closeButton.text = "✕"
        closeButton.textColor = UIColor.white
        closeButton.font = UIFont(name: "Avenir-Heavy", size: 28)!
        closeButton.addGestureRecognizer(closeTap)
        contentView!.addSubview(closeButton)
    }
    
    func initViews() {
        let width: CGFloat = view.frame.width / 2 - 10
        let height: CGFloat = 54
        let marginBetweenButton:CGFloat = 4
        
        let exportToExcelLabel = UILabel(frame: CGRect(x: 0, y: 0, width: width * 2, height: height))
        exportToExcelLabel.text = "Export through Email"
        exportToExcelLabel.textColor = UIColor.white
        exportToExcelLabel.font = font
        exportToExcelLabel.isUserInteractionEnabled = true
        let exportExcelTap = UITapGestureRecognizer(target: self, action: #selector(SetUpViewController.exportExcel(_:)))
        exportToExcelLabel.addGestureRecognizer(exportExcelTap)
        
        let exportToExcelView = UIView(frame: CGRect(x: 10, y: 64 + marginBetweenButton, width: width * 2, height: height))
        exportToExcelView.addSubview(exportToExcelLabel)
        
        let suggestionToMeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: width * 2, height: height))
        suggestionToMeLabel.text = "Suggestions"
        suggestionToMeLabel.textColor = UIColor.white
        suggestionToMeLabel.font = font
        suggestionToMeLabel.isUserInteractionEnabled = true
        let suggestionToMeTap = UITapGestureRecognizer(target: self, action: #selector(SetUpViewController.suggestionToMe(_:)))
        suggestionToMeLabel.addGestureRecognizer(suggestionToMeTap)
        
        let suggestionToMeView = UIView(frame: CGRect(x: 10, y: 64 + height + marginBetweenButton * 2, width: width * 2, height: height))
        suggestionToMeView.addSubview(suggestionToMeLabel)
        
        let themeLabel = UILabel(frame: CGRect(x: 10, y: 64 + height * 2 + marginBetweenButton * 3, width: width * 2, height: height))
        themeLabel.text = "Themes"
        themeLabel.textColor = UIColor.white
        themeLabel.font = font
        themeLabel.isUserInteractionEnabled = true
        let themeTap = UITapGestureRecognizer(target: self, action: #selector(SetUpViewController.showThemeView(_:)))
        themeLabel.addGestureRecognizer(themeTap)
        
        let categoriesLabel = UILabel(frame: CGRect(x: 10, y: 64 + height * 3 + marginBetweenButton * 4, width: width * 2, height: height))
        categoriesLabel.text = "Categories"
        categoriesLabel.textColor = UIColor.white
        categoriesLabel.font = font
        categoriesLabel.isUserInteractionEnabled = true
        let categoriesTap = UITapGestureRecognizer(target: self, action: #selector(SetUpViewController.showCatagoriesView(_:)))
        categoriesLabel.addGestureRecognizer(categoriesTap)
        
        contentView!.addSubview(exportToExcelView)
        contentView!.addSubview(suggestionToMeView)
        contentView!.addSubview(themeLabel)
        contentView!.addSubview(categoriesLabel)
    }
    
//MARK: action
    func JustCloseSetUpView(_ sender: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.3, animations: {
            self.contentView!.alpha = 0
            self.contentView!.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }, completion: {_ in
                self.performSegue(withIdentifier: "closeSetUpView", sender: self)
        })
    }
    
    func showThemeView(_ sender: UITapGestureRecognizer) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "themeView") as! ThemeViewController
        self.present(vc, animated: true, completion: nil)
    }
    
    func showCatagoriesView(_ sender: UITapGestureRecognizer) {
        let vc = CatagoriesViewController()
        self.present(vc, animated: true, completion: nil)
    }
    
    func toggleAutoSync(_ sender: UITapGestureRecognizer) {
        if autoSyncTip!.text == "YES" {
            autoSyncTip?.text = "NO"
            print("open auto sync")
        } else {
            autoSyncTip?.text = "YES"
            print("close auto sync")
        }
    }
    
    func syncNow(_ sender: UITapGestureRecognizer) {
        
    }
    
    func exportExcel(_ sender: UITapGestureRecognizer) {
        let mailComposeViewController = configuredExportDataMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    func suggestionToMe(_ sender: UITapGestureRecognizer) {
        let mailComposeViewController = configuredSentToMeMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
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
        
        _ = (FileManager.default)
        let directorys : [String]? = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory,FileManager.SearchPathDomainMask.allDomainsMask, true) as [String]
        
        if ((directorys) != nil) {
            
            let directories:[String] = directorys!;
            let dictionary = directories[0];
            let plistfile = "/cost-data.csv"
            let plistpath = dictionary + plistfile
            
            do {
                try data.write(toFile: plistpath, atomically: true, encoding: String.Encoding.utf8)
            } catch let error as NSError  {
                print(error)
            }
            let costData: Data = try! Data(contentsOf: URL(fileURLWithPath: plistpath))
            mailComposerVC.addAttachmentData(costData, mimeType: "text/csv", fileName: "cost-data.csv")
        }
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    // MARK: MFMailComposeViewControllerDelegate
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        
    }
    
    func compileDataToExcel() -> String {
        let items = getAllDataFromDatabase()
        var data = "Index,Price,Kind,Detail,Time\n"
        if items != nil {
            for (index, item) in items!.enumerated() {
                data += "\(index),\(String(format: "%.2f", Float(item.price))),\(item.kind),\(item.detail),\(item.year)-\(item.month)-\(item.day) \(item.addTime)\n"
            }
        }
        return data
    }
    
//MARK: get data from database
    func getAllDataFromDatabase() -> [ItemModel]? {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ItemModel")
        
        fetchRequest.predicate = NSPredicate(format: "kill == false")
        
        var fetchResults: [ItemModel]?
        do {
            fetchResults = try managedContext.fetch(fetchRequest) as? [ItemModel]
        } catch let error as NSError {
            print(error)
        }
        return fetchResults
    }
}
