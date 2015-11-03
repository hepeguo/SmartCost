//
//  ListPageScrollView.swift
//  $Mate
//
//  Created by 郭振永 on 15/4/8.
//  Copyright (c) 2015年 guozy. All rights reserved.
//

import UIKit

protocol ListPageScrollViewDelegate {
    func next()
    func prev()
    func afterAutoScroll()
}

class ListPageScrollView: UIView, UIScrollViewDelegate {

    var delegate: ListPageScrollViewDelegate?
    
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
        scrollView.setContentOffset(CGPointMake(frame.width, 0), animated: false)
        
        scrollView.pagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.scrollsToTop = false
        scrollView.directionalLockEnabled = true
        scrollView.delegate = self
        
        for (var i = 0; i < count; i++) {
            views[i].frame = CGRectMake(frame.width * CGFloat(i), 0, frame.width, frame.height)
            scrollView.addSubview(views[i])
        }
        
        self.scrollView = scrollView
        self.addSubview(scrollView)
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if(scrollView.contentOffset.x > frame.width) {
            delegate?.next()
        } else if (scrollView.contentOffset.x < frame.width) {
            delegate?.prev()
        }
        scrollView.setContentOffset(CGPointMake(frame.width, 0), animated: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func autoScrollLeft() {
        scrollView.setContentOffset(CGPointMake(0, 0), animated: true)
        
    }
    
    func autoScrollRight() {
        scrollView.setContentOffset(CGPointMake(scrollView.frame.width * 2, 0), animated: true)
    }
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        scrollView.setContentOffset(CGPointMake(frame.width, 0), animated: false)
        delegate!.afterAutoScroll()
    }
}
