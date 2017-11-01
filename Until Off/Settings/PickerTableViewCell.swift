//
//  PickerTableViewCell.swift
//  Until Off
//
//  Created by dasdom on 18.10.14.
//  Copyright (c) 2014 dasdom. All rights reserved.
//

import UIKit

class PickerTableViewCell: UITableViewCell {

    let pickerView: UIPickerView
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        pickerView = UIPickerView()
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        
        super.init(style: UITableViewCellStyle.default, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(pickerView)
        
        let views = ["pickerView" : pickerView]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[pickerView]|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[pickerView]|", options: [], metrics: nil, views: views))
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
