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
        scrollView.setContentOffset(CGPoint(x: frame.width, y: 0), animated: false)
        
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
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if(scrollView.contentOffset.x > frame.width) {
            delegate?.next()
        } else if (scrollView.contentOffset.x < frame.width) {
            delegate?.prev()
        }
        scrollView.setContentOffset(CGPoint(x: frame.width, y: 0), animated: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func autoScrollLeft() {
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        
    }
    
    func autoScrollRight() {
        scrollView.setContentOffset(CGPoint(x: scrollView.frame.width * 2, y: 0), animated: true)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollView.setContentOffset(CGPoint(x: frame.width, y: 0), animated: false)
        delegate!.afterAutoScroll()
    }
}
