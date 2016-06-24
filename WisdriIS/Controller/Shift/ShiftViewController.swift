//
//  ShiftViewController.swift
//  WisdriIS
//
//  Created by Allen on 5/3/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit
import CVCalendar
import SVProgressHUD
import SwiftDate
import Ruler

class ShiftViewController: UIViewController {

    @IBOutlet weak var menuView: CVCalendarMenuView!
    @IBOutlet weak var calendarView: CVCalendarView!
    
    @IBOutlet weak var shiftTableView: UITableView!
    @IBOutlet weak var monthLabel: UILabel!
    
    @IBOutlet weak var calendarViewHeightConstraint: NSLayoutConstraint!
    
    private let cellIdentifier = "ClockInfoCell"

    private var animationFinished = true
    
    private var selectedDay: DayView!
    
    private var clockRecords = [WISClockRecord]()
    
    private lazy var todayButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: NSLocalizedString("Today", comment: ""), style: .Plain, target: self, action: #selector(ShiftViewController.todayMonthView))
        button.enabled = true
        return button
    }()
    
    private lazy var noRecordsFooterView: InfoView = InfoView(NSLocalizedString("No clock records", comment: ""))
    
    private var noRecords = false {
        didSet {
            if noRecords != oldValue {
                shiftTableView.tableFooterView = noRecords ? noRecordsFooterView : UIView()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        monthLabel.text = NSLocalizedString("Shift") + " ｜ " + CVDate(date: NSDate()).globalDescription
        // 增加了 TodayButton 后，Title 会往左偏移一点，后续待解决
        navigationItem.rightBarButtonItem = todayButton
        shiftTableView.registerNib(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
        shiftTableView.tableFooterView = UIView()
        
        noRecords = clockRecords.isEmpty
        
        let now = NSDate()
        getClockRecords(now, endDate: now)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        menuView.commitMenuViewUpdate()
        calendarView.commitCalendarViewUpdate()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc private func todayMonthView() {
        self.calendarView.toggleCurrentDayView()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // 获取从 startDate 至 endDate 之间的打卡记录
    private func getClockRecords(startDate: NSDate, endDate: NSDate) {
        
        SVProgressHUD.setDefaultMaskType(.None)
        SVProgressHUD.show()
        WISDataManager.sharedInstance().updateClockRecordsWithStartDate(startDate, endDate: endDate) { (completedWithNoError, error, classNameOfDataAsString, data) in
            if completedWithNoError {
                
                SVProgressHUD.dismiss()
                let records = data as! Array<WISClockRecord>
                self.clockRecords.removeAll()
                
                for record in records {
                    self.clockRecords.append(record)
                }
                
                if self.clockRecords.isEmpty {
                    self.shiftTableView.contentOffset = CGPoint(x: 0, y: Ruler.iPhoneVertical(95, 50, 0, 0).value)
                } else {
                    self.shiftTableView.contentOffset = CGPoint()
                }
                
                self.noRecords = self.clockRecords.isEmpty
                self.shiftTableView.reloadData()
                
            } else {
                WISConfig.errorCode(error)
            }
        }
    }
    
    // Deprecated
    private func convertDateToDayView(date: NSDate) -> CVCalendarDayView {
        
        let date = date
        let monthView = CVCalendarMonthView(calendarView: calendarView, date: date)
        let weekView = CVCalendarWeekView(monthView: monthView, index: date.weekOfMonth - 1)
        let dayView = CVCalendarDayView(weekView: weekView, weekdayIndex: date.weekday)
        return dayView
    }

}

// MARK: - CVCalendarViewDelegate

extension ShiftViewController: CVCalendarViewDelegate {
    
    /// Required method to implement!
    func presentationMode() -> CalendarMode {
        return .MonthView
    }
    
    func firstWeekday() -> Weekday {
        return .Sunday
    }
    
    // MARK: Optional methods
    
    func shouldShowWeekdaysOut() -> Bool {
        return false
    }
    
    // Default value is true
    func shouldAnimateResizing() -> Bool {
        return true
    }
    
    func didSelectDayView(dayView: CVCalendarDayView, animationDidFinish: Bool) {
//        print("\(dayView.date.commonDescription) is selected!")

        // 获取选择当天的打卡记录
        selectedDay = dayView
        getClockRecords(selectedDay.date.convertedDate()!, endDate: selectedDay.date.convertedDate()!)
        
        // 获取当月、去年、明年的排班记录
        // 十分丑陋的实现方式，待优化
        let dayOfSelectDay = dayView.date.day
        let monthOfSelectDay = dayView.date.month
        let yearOfSelectYear = dayView.date.year
        
        let dateOfSelectDay = NSDate(year: yearOfSelectYear , month: monthOfSelectDay, day: dayOfSelectDay)
        if workShifts[dateOfSelectDay.toString()!] == nil {
            WISUserDefaults.getWorkShift(dateOfSelectDay, range: .Month)
        }
        
        if monthOfSelectDay <= 3 {
            let previewYear = NSDate(year: yearOfSelectYear - 1, month: monthOfSelectDay, day: dayOfSelectDay)
            if workShifts[previewYear.toString()!] == nil {
                WISUserDefaults.getWorkShift(previewYear, range: .Year)
            }
        }
        
        if monthOfSelectDay >= 10 {
            let nextYear = NSDate(year: yearOfSelectYear + 1, month: monthOfSelectDay, day: dayOfSelectDay)
            if workShifts[nextYear.toString()!] == nil {
                WISUserDefaults.getWorkShift(nextYear, range: .Year)
            }
        }
        
        
    }
    
    func presentedDateUpdated(date: CVDate) {
        
//        let nsdate = date.convertedDate()
//        WISUserDefaults.getWorkShift(nsdate!)
//        print(workShifts.count)
        
//        for (dateString, shift) in workShifts {
//            print("\(dateString) 的排班记录为 \(shift)")
//        }
        
        if monthLabel.text != date.globalDescription && self.animationFinished {
            let updatedMonthLabel = UILabel()
            updatedMonthLabel.textColor = monthLabel.textColor
            updatedMonthLabel.font = monthLabel.font
            updatedMonthLabel.textAlignment = .Center
            updatedMonthLabel.text = NSLocalizedString("Shift") + " ｜ " + date.globalDescription
            updatedMonthLabel.sizeToFit()
            updatedMonthLabel.alpha = 0
            updatedMonthLabel.center = self.monthLabel.center
            
            UIView.animateWithDuration(0.35, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                self.animationFinished = false
                
                updatedMonthLabel.alpha = 1
                
            }) { _ in
                
                self.animationFinished = true
                self.monthLabel.frame = updatedMonthLabel.frame
                self.monthLabel.text = updatedMonthLabel.text
                self.monthLabel.alpha = 1
                updatedMonthLabel.removeFromSuperview()
            }
            
            self.view.insertSubview(updatedMonthLabel, aboveSubview: self.monthLabel)
        }
        
    }
    
    func topMarker(shouldDisplayOnDayView dayView: CVCalendarDayView) -> Bool {
        return false
    }
    
    func dotMarker(shouldShowOnDayView dayView: CVCalendarDayView) -> Bool {
        
        let day = dayView.date.day
        let month = dayView.date.month
        let year = dayView.date.year

        let date = NSDate(year: year, month: month, day: day)
        let dateString = date.toString()!
        
        guard let shift = workShifts[dateString] else {
            return false
        }
        
        switch shift {
        case 1:
            return true
        case 2:
            return true
        case 3:
            return false
        default:
            return false
        }

    }
    
    func dotMarker(colorOnDayView dayView: CVCalendarDayView) -> [UIColor] {
        
        let clear = UIColor.clearColor()
        let tint = UIColor.wisTintColor()
        let red = UIColor.redColor()
        
        let day = dayView.date.day
        let month = dayView.date.month
        let year = dayView.date.year
        
        let date = NSDate(year: year, month: month, day: day)
        let dateString = date.toString()!
        
        guard let shift = workShifts[dateString] else {
            return [clear]
        }

        switch shift {
        case 1:
            return [tint]
        case 2:
            return [red]
        case 3:
            return [clear]
        default:
            return [clear]
        }
    }
    
    // ShouldMoveOnHighlightingOnDayView 为 True 时，今天的 dotMarker 会显示在 DayView 的上方
    // 改为 false 以解决该 Bug
    func dotMarker(shouldMoveOnHighlightingOnDayView dayView: CVCalendarDayView) -> Bool {
        return false
    }
    
    func dotMarker(sizeOnDayView dayView: DayView) -> CGFloat {
        return 15
    }
 
    /*
    func selectionViewPath() -> ((CGRect) -> (UIBezierPath)) {
        return { UIBezierPath(rect: CGRectMake(0, 0, $0.width, $0.height)) }
    }
    
    func shouldShowCustomSingleSelection() -> Bool {
        return false
    }
    
    func preliminaryView(viewOnDayView dayView: DayView) -> UIView {
        let circleView = CVAuxiliaryView(dayView: dayView, rect: dayView.bounds, shape: CVShape.Circle)
        circleView.fillColor = .colorFromCode(0xCCCCCC)
        return circleView
    }
    
    func preliminaryView(shouldDisplayOnDayView dayView: DayView) -> Bool {
        if (dayView.isCurrentDay) {
            return true
        }
        return false
    }
    
    func supplementaryView(viewOnDayView dayView: DayView) -> UIView {
        let π = M_PI
        
        let ringSpacing: CGFloat = 3.0
        let ringInsetWidth: CGFloat = 1.0
        let ringVerticalOffset: CGFloat = 1.0
        var ringLayer: CAShapeLayer!
        let ringLineWidth: CGFloat = 4.0
        let ringLineColour: UIColor = .blueColor()
        
        let newView = UIView(frame: dayView.bounds)
        
        let diameter: CGFloat = (newView.bounds.width) - ringSpacing
        let radius: CGFloat = diameter / 2.0
        
        let rect = CGRectMake(newView.frame.midX-radius, newView.frame.midY-radius-ringVerticalOffset, diameter, diameter)
        
        ringLayer = CAShapeLayer()
        newView.layer.addSublayer(ringLayer)
        
        ringLayer.fillColor = nil
        ringLayer.lineWidth = ringLineWidth
        ringLayer.strokeColor = ringLineColour.CGColor
        
        let ringLineWidthInset: CGFloat = CGFloat(ringLineWidth/2.0) + ringInsetWidth
        let ringRect: CGRect = CGRectInset(rect, ringLineWidthInset, ringLineWidthInset)
        let centrePoint: CGPoint = CGPointMake(ringRect.midX, ringRect.midY)
        let startAngle: CGFloat = CGFloat(-π/2.0)
        let endAngle: CGFloat = CGFloat(π * 2.0) + startAngle
        let ringPath: UIBezierPath = UIBezierPath(arcCenter: centrePoint, radius: ringRect.width/2.0, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        ringLayer.path = ringPath.CGPath
        ringLayer.frame = newView.layer.bounds
        
        return newView
    }
    
    func supplementaryView(shouldDisplayOnDayView dayView: DayView) -> Bool {
        if (Int(arc4random_uniform(3)) == 1) {
            return true
        }
        
        return false
    }
 
 */
}

// MARK: - CVCalendarMenuViewDelegate

extension ShiftViewController: CVCalendarMenuViewDelegate {

//    func dayOfWeekTextColor() -> UIColor {
//        return UIColor.wisTintColor()
//    }
    
    func dayOfWeekTextUppercase() -> Bool {
        return false
    }
    
    func dayOfWeekFont() -> UIFont {
        return UIFont.systemFontOfSize(13)
    }
    
    func weekdaySymbolType() -> WeekdaySymbolType {
        return .Short
    }
}

// MARK: - CVCalendarViewAppearanceDelegate

extension ShiftViewController: CVCalendarViewAppearanceDelegate {
    
    func dayLabelPresentWeekdayInitallyBold() -> Bool {
        return false
    }
    
    func spaceBetweenDayViews() -> CGFloat {
        return 2
    }
}

extension ShiftViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clockRecords.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! ClockInfoCell
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        guard let cell = cell as? ClockInfoCell else {
            return
        }
        
        let record = clockRecords[indexPath.row]

        cell.infoLabel.text = record.clockActionTime.toDateTimeString()
        
        switch record.clockAction {
        case .In:
            cell.clockImageView.image = UIImage(named: "icon_clock_active")
            cell.annotationLabel.text = NSLocalizedString("Clock in")
        case .Off:
            cell.clockImageView.image = UIImage(named: "icon_clock")
            cell.annotationLabel.text = NSLocalizedString("Clock out")
        default:
            cell.clockImageView.image = UIImage(named: "icon_fault")
            cell.annotationLabel.text = NSLocalizedString("Undefined")
        }
        
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
   
//    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        
//        let hideCalendar: (() -> Void)? = {
//        
//            let translation = scrollView.panGestureRecognizer.translationInView(scrollView.superview)
//            
//            if translation.y > 0 && self.calendarViewHeightConstraint.constant < 150 {
//                self.calendarViewHeightConstraint.constant = self.calendarViewHeightConstraint.constant + 150
//            } else if translation.y < 0 && self.calendarViewHeightConstraint.constant > 150 {
//                self.calendarViewHeightConstraint.constant = self.calendarViewHeightConstraint.constant - 150
//            }
//        }
//        
//        Ruler.iPhoneVertical(hideCalendar, hideCalendar, nil, nil).value?()
//    }
}
