//
//  MyCustomCalendarCell.swift
//  HorizontalCalendarExample
//
//  Created by Raphael Seher on 25/01/16.
//  Copyright © 2016 Raphael Seher. All rights reserved.
//

import UIKit
import HorizontalCalendarView

class MyCustomCalendarCell: UICollectionViewCell {
  var label : UILabel?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    label = UILabel(frame: CGRect(x: 0, y: frame.size.height/2 - 10, width: 80, height: 20))
    label?.textAlignment = .Center
    addSubview(label!)
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override func configureCalendarCell(cell: UICollectionViewCell, date: NSDate, active: Bool) -> UICollectionViewCell {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "d.MM"
    label!.text = dateFormatter.stringFromDate(date)
    label!.textColor = UIColor.whiteColor()
    
    if (active) {
      cell.backgroundColor = UIColor(red: 0, green: 0, blue: 1, alpha: 0.8)
    } else {
      cell.backgroundColor = UIColor(red: 0, green: 0, blue: 1, alpha: 0.4)
    }
    
    return cell;
  }
}