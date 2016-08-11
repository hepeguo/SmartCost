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
        self.backgroundColor = UIColor.clearColor()
    }
    
    init(frame: CGRect, views: Array<UIView>){
        super.init(frame: frame)
        self.frame = frame
        self.userInteractionEnabled = true
        self.backgroundColor = UIColor.clearColor()
        
        let count = views.count
        
        let scrollView = UIScrollView(frame: CGRectMake(0, 0, frame.width, frame.height))
        scrollView.contentSize = CGSizeMake(frame.width * CGFloat(count), frame.height)
        scrollView.setContentOffset(CGPointMake(0, 0), animated: false)
        
        scrollView.pagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.scrollsToTop = false
        scrollView.directionalLockEnabled = true
        scrollView.delegate = self
        
        for i in 0 ..< count {
            views[i].frame = CGRectMake(frame.width * CGFloat(i), 0, frame.width, frame.height)
            scrollView.addSubview(views[i])
        }
        
        self.scrollView = scrollView
        self.addSubview(scrollView)
        
        //title
        
        let noteView = UIView(frame: CGRectMake(0, self.bounds.size.height - 30.0, frame.width, 20))
        
        let pageControlWidth = CGFloat(count - 2) * 10.0 + 40.0
        let pageControlHeight = CGFloat(20.0)
        let pageControl = UIPageControl(frame: CGRectMake((frame.width - pageControlWidth) / 2, 6, pageControlWidth, pageControlHeight))
        pageControl.currentPage = 0;
        pageControl.numberOfPages = count
        self.pageControl = pageControl
        noteView.addSubview(pageControl)
        
        self.addSubview(noteView)

    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        let pageWidth = frame.width
        let page = Int(floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth)) + 1
        pageControl.currentPage = page
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func scrollTo(point: CGPoint) {
        scrollView.setContentOffset(point, animated: false)        
    }
}
