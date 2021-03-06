//
//  HorizontalCalendarView.swift
//  HorizontalCalendar
//
//  Created by Raphael Seher on 27/12/15.
//  Copyright © 2015 Raphael Seher. All rights reserved.
//

import UIKit

public class HorizontalCalendarView: UIView {
  let cellReuseIdentifier = "CalendarCellReuseIdentifier"
  let horizontalCalendar = HorizontalCalendar()
  
  public var delegate : HorizontalCalendarDelegate?
  public var collectionView : UICollectionView?
  public var mininumLineSpacing : CGFloat = 0.0
  public var minimumInterItemSpacing : CGFloat = 0.0
  
  var dates : [NSDate] = []
  var displayedYears : [Int] = []
  var startingYear : Int?
  var cellWidth : CGFloat = 80
  var activeIndexPath : NSIndexPath?
  
  var collectionViewTopConstraint : NSLayoutConstraint?
  var collectionViewBottomConstraint : NSLayoutConstraint?
  var collectionViewLeadingConstraint : NSLayoutConstraint?
  var collectionViewTrailingConstraint : NSLayoutConstraint?
  
  /**
   Create a instance of HorizontalCalendarView with rect.
   
   - Parameter frame: CGRect for frame.
   */
  public override init(frame: CGRect) {
    super.init(frame: frame)
    collectionView = UICollectionView(frame: CGRect(origin: CGPoint.zero, size: frame.size), collectionViewLayout: CalendarFlowLayout(cellWidth: CGFloat(cellWidth)))
    collectionView!.registerNib(UINib(nibName: "CalendarCollectionViewCell", bundle: NSBundle(forClass: HorizontalCalendarView.self)), forCellWithReuseIdentifier: cellReuseIdentifier)
    setupCollectionView()
    setupYears()
  }
  
  /**
   Create a instance of HorizontalCalendarView with rect, 
   the cellWidth and a custom nib.
   
   - Parameter frame: CGRect for frame.
   - Parameter cellWidth: Width of your custom cell.
   - Parameter cellNib: Nib of your custom cell.
   */
  public init(frame: CGRect, cellWidth: Float, cellNib: UINib) {
    super.init(frame: frame)
    self.cellWidth = CGFloat(cellWidth)
    collectionView = UICollectionView(frame: CGRect(origin: CGPoint.zero, size: frame.size), collectionViewLayout: CalendarFlowLayout(cellWidth: self.cellWidth))
    collectionView!.registerNib(cellNib, forCellWithReuseIdentifier: cellReuseIdentifier)
    setupCollectionView()
    setupYears()
  }
  
  /**
   Create a instance of HorizontalCalendarView with rect,
   the cellWidth and a custom class.
   
   - Parameter frame: CGRect for frame.
   - Parameter cellWidth: Width of your custom cell.
   - Parameter cellClass: Class of your custom cell.
   */
  public init(frame: CGRect, cellWidth: Float, cellClass: AnyClass) {
    super.init(frame: frame)
    self.cellWidth = CGFloat(cellWidth)
    collectionView = UICollectionView(frame: CGRect(origin: CGPoint.zero, size: frame.size), collectionViewLayout: CalendarFlowLayout(cellWidth: self.cellWidth))
    collectionView!.registerClass(cellClass, forCellWithReuseIdentifier: cellReuseIdentifier)
    setupCollectionView()
    setupYears()
  }
  
  /**
   Create a instance of HorizontalCalendarView with coder.
   
   - Parameter aDecoder: A coder.
   */
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    collectionView = UICollectionView(coder: aDecoder)!
    collectionView!.collectionViewLayout = CalendarFlowLayout(cellWidth: CGFloat(cellWidth))
    collectionView!.registerNib(UINib(nibName: "CalendarCollectionViewCell", bundle: NSBundle(forClass: HorizontalCalendarView.self)), forCellWithReuseIdentifier: cellReuseIdentifier)
    setupCollectionView()
    setupYears()
  }
  
  func setupCollectionView() {
    if let collectionView = collectionView {
      collectionView.backgroundColor = UIColor.clearColor()
      collectionView.delegate = self
      collectionView.dataSource = self
      collectionView.translatesAutoresizingMaskIntoConstraints = false
      collectionView.showsHorizontalScrollIndicator = false
      
      addSubview(collectionView)
      
      collectionViewTopConstraint = NSLayoutConstraint(item: collectionView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 0)
      collectionViewBottomConstraint = NSLayoutConstraint(item: collectionView, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: 0)
      collectionViewLeadingConstraint = NSLayoutConstraint(item: collectionView, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1.0, constant: 0)
      collectionViewTrailingConstraint = NSLayoutConstraint(item: collectionView, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1.0, constant: 0)
      addConstraints([collectionViewTopConstraint!, collectionViewBottomConstraint!, collectionViewLeadingConstraint!, collectionViewTrailingConstraint!])
    }
  }
  
  func setupYears() {
    startingYear = horizontalCalendar.currentYear()
    if let year = startingYear {
      dates = horizontalCalendar.datesForYear(year)
      displayedYears.append(year)
    }
  }
  
  func addDatesFromYear(year: Int) {
    if displayedYears.contains(year) {
      return
    }
    
    if let indexPath = activeIndexPath {
      let currentDate = dates[indexPath.row]
      
      if year > startingYear {
        dates.appendContentsOf(horizontalCalendar.datesForYear(year))
      } else if (year < startingYear) {
        let newDates = horizontalCalendar.datesForYear(year)
        dates.insertContentsOf(newDates, at: 0)
      }
      
      displayedYears.append(year)
      collectionView?.reloadData()
      moveToDate(currentDate, animated: false)
    }
  }
  
  func updateActiveIndexPath(indexPath : NSIndexPath) {
    if activeIndexPath != indexPath {
      activeIndexPath = indexPath
      collectionView?.reloadData()
      
      delegate?.horizontalCalendarViewDidUpdate(self, date: dates[indexPath.row])
    }
  }
  
  public func moveToDate(date : NSDate, animated : Bool) {
    let indexOfDate = dates.indexOf(horizontalCalendar.truncateDateToYearMonthDay(date))
    let indexPath = NSIndexPath.init(forItem: indexOfDate!, inSection: 0)
    collectionView?.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredHorizontally, animated: animated)
  }
  
  public func checkForEndOfDates(scrollView: UIScrollView) {
    if scrollView.contentOffset.x < 60 * cellWidth {
      let minYearDisplayed = displayedYears.minElement();
      if let lastYear = minYearDisplayed {
        addDatesFromYear(lastYear - 1)
        return;
      }
    }
    
    let maxLinespacing = (self.mininumLineSpacing * CGFloat(dates.count - 1))
    let maxDateSize = cellWidth * CGFloat(dates.count) + maxLinespacing
    let maxScrollviewOffset = maxDateSize - collectionView!.bounds.size.width
    let offsetToLoadMore = maxScrollviewOffset - 60 * cellWidth
    
    if scrollView.contentOffset.x > offsetToLoadMore {
      let minYearDisplayed = displayedYears.maxElement();
      if let lastYear = minYearDisplayed {
        addDatesFromYear(lastYear + 1)
      }
    }
  }
}

extension HorizontalCalendarView : UICollectionViewDelegate {
  func collectionView(collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
      return mininumLineSpacing;
  }
  
  func collectionView(collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
      return minimumInterItemSpacing;
  }
}

extension HorizontalCalendarView : UICollectionViewDataSource {
  public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 1
  }
  
  public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return dates.count
  }
  
  public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellReuseIdentifier, forIndexPath: indexPath)
    cell.configureCalendarCell(cell, date: dates[indexPath.row], active: (indexPath == activeIndexPath))
    return cell
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    return CGSize(width: cellWidth, height: collectionView.bounds.height)
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
    return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
  }
}

extension HorizontalCalendarView : UIScrollViewDelegate {
  public func scrollViewDidScroll(scrollView: UIScrollView) {
    if let indexPath = collectionView?.indexPathForItemAtPoint(CGPoint(x: collectionView!.center.x + scrollView.contentOffset.x, y: collectionView!.center.y)) {
      updateActiveIndexPath(indexPath)
    }
  }
  
  public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
    checkForEndOfDates(scrollView)
  }
  
  public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    checkForEndOfDates(scrollView)
  }
}

