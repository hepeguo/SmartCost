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
            if item?.price != nil {
                let priceString = NSString(format: "%.2f", item!.price)
                priceLabel.text = priceString as String
            }
            detailLabel.text = item?.detail
            kindLabel.text = item?.kind
            timeLabel.text = item?.time
            kindImage.image = UIImage(named: item!.imageName)
        }
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        priceLabel = UILabel(frame: CGRect.null)
        priceLabel.textColor = UIColor.white
        priceLabel.font = UIFont.boldSystemFont(ofSize: 25)
        priceLabel.backgroundColor = UIColor.clear
        priceLabel.adjustsFontSizeToFitWidth = true
        priceLabel.textAlignment = .right
        priceLabel.text = "\(item?.price)"
        
        detailLabel = UILabel(frame: CGRect.null)
        detailLabel.textColor = UIColor.white
        detailLabel.font = UIFont.boldSystemFont(ofSize: 16)
        detailLabel.backgroundColor = UIColor.clear
        detailLabel.textAlignment = .left
        detailLabel.numberOfLines = 2
        detailLabel.text = item?.detail
        
        timeLabel = UILabel(frame: CGRect.null)
        timeLabel.textColor = UIColor.white
        timeLabel.font = UIFont.systemFont(ofSize: 16)
        timeLabel.backgroundColor = UIColor.clear
        timeLabel.textAlignment = .right
        timeLabel.text = item?.time
        
        dotLine = DashLine()
        dotLine.backgroundColor = UIColor.clear
        
        
        kindLabel = UILabel(frame: CGRect.null)
        kindLabel.textColor = UIColor.white
        kindLabel.font = UIFont.systemFont(ofSize: 16)
        kindLabel.backgroundColor = UIColor.clear
        kindLabel.textAlignment = .left
        kindLabel.text = item?.kind
        
        kindImage = UIImageView()     
        
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
        selectionStyle = .none
    }

    required init?(coder aDecoder: NSCoder) {
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
        contentView.frame = CGRect(x: marginLR, y: marginTB, width: bounds.size.width - marginLR * 2, height: contentHeight)
        
        kindImage.frame = CGRect(x: paddingLR, y: marginTB, width: imageSize, height: imageSize)
        kindLabel.frame = CGRect(x: imageSize + paddingLR + 5.0, y: paddingTB, width: contentView.frame.width - imageSize - 2 * paddingLR, height: imageSize)
        timeLabel.frame = CGRect(x: paddingLR + imageSize + kindLabelWidth, y: paddingTB, width: contentView.frame.width - imageSize - 2 * paddingLR - kindLabelWidth, height: 20)
        
        dotLine.frame = CGRect(x: 0, y: imageSize + paddingTB * 2, width: contentView.frame.width, height: 1.0)
        
        detailLabel.frame = CGRect(x: paddingLR, y: imageSize + paddingTB * 3 + 1, width: contentView.frame.width / 2 - paddingLR, height: contentView.frame.height - paddingTB * 4 - 1 - imageSize)
        priceLabel.frame = CGRect(x: contentView.frame.width / 2, y: imageSize + paddingTB * 3 + 1 , width: contentView.frame.width / 2 - paddingLR, height: contentView.frame.height - paddingTB * 4 - 1 - imageSize)
    }
}
