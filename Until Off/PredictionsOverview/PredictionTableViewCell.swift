//
//  PredictionTableViewCell.swift
//  Until Off
//
//  Created by dasdom on 07.10.15.
//  Copyright © 2015 dasdom. All rights reserved.
//

import UIKit

class PredictionTableViewCell: UITableViewCell {

    let timeLabel: UILabel
    let dateLabel: UILabel
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        timeLabel = UILabel()
        
        dateLabel = UILabel()
        
        let stackView = UIStackView(arrangedSubviews: [timeLabel, dateLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(stackView)
        
        let views = ["stackView": stackView]
        var layoutConstraints = [NSLayoutConstraint]()
        
        layoutConstraints += NSLayoutConstraint.constraints(withVisualFormat: "|-[stackView]-|", options: [], metrics: nil, views: views)
        layoutConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|[stackView]|", options: [], metrics: nil, views: views)
        
        NSLayoutConstraint.activate(layoutConstraints)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
