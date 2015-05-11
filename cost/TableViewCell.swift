//
//  TableViewCell.swift
//  $Mate
//
//  Created by 郭振永 on 15/3/31.
//  Copyright (c) 2015年 guozy. All rights reserved.
//

import UIKit
import QuartzCore

class TableViewCell: UITableViewCell {
    let priceLabel: UILabel
    let detailLabel: UILabel
    let timeLabel: UILabel
    let kindImage: UIImageView
    let kindLabel: UILabel
    let dotLine: UIView
    
    var item: Item? {
        didSet {
            priceLabel.text = "\(item!.price)"
            detailLabel.text = item?.detail
            kindLabel.text = item?.kind
            timeLabel.text = item?.time
        }
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        priceLabel = UILabel(frame: CGRect.nullRect)
        priceLabel.textColor = UIColor.whiteColor()
        priceLabel.font = UIFont.boldSystemFontOfSize(25)
        priceLabel.backgroundColor = UIColor.clearColor()
        priceLabel.textAlignment = .Right
        priceLabel.text = "\(item?.price)"
        
        detailLabel = UILabel(frame: CGRect.nullRect)
        detailLabel.textColor = UIColor.whiteColor()
        detailLabel.font = UIFont.boldSystemFontOfSize(16)
        detailLabel.backgroundColor = UIColor.clearColor()
        detailLabel.textAlignment = .Left
        detailLabel.numberOfLines = 2
        detailLabel.text = item?.detail
        
        timeLabel = UILabel(frame: CGRect.nullRect)
        timeLabel.textColor = UIColor.whiteColor()
        timeLabel.font = UIFont.systemFontOfSize(16)
        timeLabel.backgroundColor = UIColor.clearColor()
        timeLabel.textAlignment = .Right
        timeLabel.text = item?.time
        
        dotLine = DashLine()
        dotLine.backgroundColor = UIColor.clearColor()
        
        
        kindLabel = UILabel(frame: CGRect.nullRect)
        kindLabel.textColor = UIColor.whiteColor()
        kindLabel.font = UIFont.systemFontOfSize(16)
        kindLabel.backgroundColor = UIColor.clearColor()
        kindLabel.textAlignment = .Left
        kindLabel.text = item?.kind
        
        kindImage = UIImageView()
        kindImage.image = UIImage(named: "house1")
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(priceLabel)
        contentView.addSubview(detailLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(dotLine)
        contentView.addSubview(kindImage)
        contentView.addSubview(kindLabel)
        
        contentView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.15)
        contentView.layer.cornerRadius = 3
        addSubview(contentView)
        selectionStyle = .None
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    let contentHeight: CGFloat = 100.0
    let marginLR: CGFloat = 10.0
    let marginTB: CGFloat = 5.0
    let paddingLR: CGFloat = 10.0
    let paddingTB: CGFloat = 5.0
    
    let imageSize: CGFloat = 20.0
    let kindLabelWidth: CGFloat = 40.0
    
    let kUICuesWidth: CGFloat = 50.0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = CGRectMake(marginLR, marginTB, bounds.size.width - marginLR * 2, contentHeight)
        
        kindImage.frame = CGRect(x: paddingLR, y: marginTB, width: imageSize, height: imageSize)
        kindLabel.frame = CGRect(x: imageSize + paddingLR + 5.0, y: paddingTB, width: contentView.frame.width - imageSize - 2 * paddingLR, height: imageSize)
        timeLabel.frame = CGRect(x: paddingLR + imageSize + kindLabelWidth, y: paddingTB, width: contentView.frame.width - imageSize - 2 * paddingLR - kindLabelWidth, height: 20)
        
        dotLine.frame = CGRect(x: 0, y: imageSize + paddingTB * 2, width: contentView.frame.width, height: 1.0)
        
        detailLabel.frame = CGRect(x: paddingLR, y: imageSize + paddingTB * 3 + 1, width: contentView.frame.width / 2 - paddingLR, height: contentView.frame.height - paddingTB * 4 - 1 - imageSize)
        priceLabel.frame = CGRect(x: contentView.frame.width / 2, y: imageSize + paddingTB * 3 + 1 , width: contentView.frame.width / 2 - paddingLR, height: contentView.frame.height - paddingTB * 4 - 1 - imageSize)
    }
}
