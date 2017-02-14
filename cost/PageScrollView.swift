//
//  PageScrollView.swift
//  $Mate
//
//  Created by 郭振永 on 15/3/30.
//  Copyright (c) 2015年 guozy. All rights reserved.
//

import UIKit

class PageScrollView: UIView, UIScrollViewDelegate {
    var currentPageIndex: Int = 0
    var titles = [String]()
    var noteTitle = UILabel()
    var scrollView = UIScrollView()
    var pageControl = UIPageControl()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
        self.backgroundColor = UIColor.clear
    }
    
    init(frame: CGRect, views: Array<UIView>, titles: Array<String>){
        super.init(frame: frame)
        self.titles = titles
        self.frame = frame
        self.isUserInteractionEnabled = true
        self.backgroundColor = UIColor.clear
        
        let count = views.count
        
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        scrollView.contentSize = CGSize(width: frame.width * CGFloat(count), height: frame.height)
        scrollView.setContentOffset(CGPoint(x: frame.width, y: 0), animated: false)
        
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.scrollsToTop = false
        scrollView.delegate = self
        
        for i in 0 ..< count {
            views[i].frame = CGRect(x: frame.width * CGFloat(i), y: 0, width: frame.width, height: frame.height)
            scrollView.addSubview(views[i])
        }
        
        self.scrollView = scrollView
        self.addSubview(scrollView)
        
        //title
        let noteView = UIView(frame: CGRect(x: 0, y: self.bounds.size.height - 33.0, width: frame.width, height: 33))
        noteView.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.5)
        
        let pageControlWidth = CGFloat(count - 2) * 10.0 + 40.0
        let pageControlHeight = CGFloat(20.0)
        let pageControl = UIPageControl(frame: CGRect(x: frame.width - pageControlWidth, y: 6, width: pageControlWidth, height: pageControlHeight))
        pageControl.currentPage = 0;
        pageControl.numberOfPages = count - 2
        self.pageControl = pageControl
        noteView.addSubview(pageControl)
        
        let noteTitle = UILabel(frame: CGRect(x: 5, y: 6, width: frame.width - pageControlWidth, height: 20))
        noteTitle.text = titles[0]
        noteTitle.backgroundColor = UIColor.clear
        noteTitle.font = UIFont.systemFont(ofSize: 13)
        self.noteTitle = noteTitle
        noteView.addSubview(noteTitle)
        
        self.addSubview(noteView)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = frame.width
        let page = Int(floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth)) + 1
        currentPageIndex = page
        pageControl.currentPage = (page - 1)
        var titleIndex = page - 1
        if (titleIndex == titles.count) {
            titleIndex = 0
        }
        if (titleIndex < 0){
            titleIndex = titles.count - 1
        }
        noteTitle.text = titles[titleIndex]
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if(currentPageIndex == 0) {
            scrollView.setContentOffset(CGPoint(x: CGFloat(titles.count) * frame.width, y: 0), animated: false)
        }
        if(currentPageIndex == titles.count + 1) {
            scrollView.setContentOffset(CGPoint(x: frame.width, y: 0), animated: false)
        }
    }
    
    func imagePressed(_ sender: UITapGestureRecognizer) {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


}
