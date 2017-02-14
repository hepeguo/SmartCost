//
//  pageView.swift
//  $Mate
//
//  Created by 郭振永 on 15/3/17.
//  Copyright (c) 2015年 guozy. All rights reserved.
//

import UIKit

class PageView: UIView, UIScrollViewDelegate {
    var currentPageIndex: Int = 0
    var scrollView = UIScrollView()
    var pageControl = UIPageControl()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
        self.backgroundColor = UIColor.clear
    }
    
    init(frame: CGRect, views: Array<UIView>){
        super.init(frame: frame)
        self.frame = frame
        self.isUserInteractionEnabled = true
        self.backgroundColor = UIColor.clear
        
        let count = views.count
        
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        scrollView.contentSize = CGSize(width: frame.width * CGFloat(count), height: frame.height)
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.scrollsToTop = false
        scrollView.isDirectionalLockEnabled = true
        scrollView.delegate = self
        
        for i in 0 ..< count {
            views[i].frame = CGRect(x: frame.width * CGFloat(i), y: 0, width: frame.width, height: frame.height)
            scrollView.addSubview(views[i])
        }
        
        self.scrollView = scrollView
        self.addSubview(scrollView)
        
        //title
        
        let noteView = UIView(frame: CGRect(x: 0, y: self.bounds.size.height - 30.0, width: frame.width, height: 20))
        
        let pageControlWidth = CGFloat(count - 2) * 10.0 + 40.0
        let pageControlHeight = CGFloat(20.0)
        let pageControl = UIPageControl(frame: CGRect(x: (frame.width - pageControlWidth) / 2, y: 6, width: pageControlWidth, height: pageControlHeight))
        pageControl.currentPage = 0;
        pageControl.numberOfPages = count
        self.pageControl = pageControl
        noteView.addSubview(pageControl)
        
        self.addSubview(noteView)

    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = frame.width
        let page = Int(floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth)) + 1
        pageControl.currentPage = page
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func scrollTo(_ point: CGPoint) {
        scrollView.setContentOffset(point, animated: false)        
    }
}
