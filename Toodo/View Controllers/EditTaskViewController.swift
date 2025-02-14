//
//  EditTaskViewController.swift
//  Toodo
//
//  Created by Reginald Suh on 2015-07-10.
//  Copyright (c) 2015 ReginaldSuh. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import FSCalendar
import SCLAlertView

class EditTaskViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var badgeImage: UIImageView!
    @IBOutlet weak var taskTextField: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var editImage: UIImageView!
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var goToCalendarScreenButton: UIButton!
    @IBOutlet weak var calendarDateLabel: UILabel!
    
    // Initialize realm
    //let realm = Realm()
    
    var badge = 0
    var orderingDate: NSDate?
    var addButtonColor: String = ""
    var editButtonImage: String = ""
    var date = ""
    var numDateLabel = ""
    var creationDate: NSDate?
    var creationDateString = ""
    
    
    
    var editedTask: Task? {
        didSet {
            displayTask(editedTask)
            displayBadge(editedTask)
            displayDate(editedTask)
        }
    }
    
    // Displays the badge
    func displayBadge(task: Task?) {
        if let task = task, editedTask = editedTask {
            
            let realm = Realm()
            
            realm.write() {
                task.badge = self.editedTask!.badge
            }
        }
    }
    
    // Displays the task
    func displayTask(task: Task?) {
        if let task = task, taskTextField = taskTextField {
            
            let realm = Realm()
            
            realm.write() {
                self.taskTextField.text = self.editedTask!.taskTitle as String
            }
        }
    }
    
    // Displays the date
    func displayDate(task: Task?) {
        if let task = task, dateLabel = dateLabel {
            
            let realm = Realm()
            
            realm.write() {
                
                //self.dateLabel.text = self.editedTask?.modificationDate
                if (self.editedTask?.modificationDate == "") {
                    self.dateLabel.text = "Set Date"
                } else {
                    self.dateLabel.text = self.editedTask?.modificationDate
                }
                println("HFLEJFKLSJFSE \(self.calendarDateLabel.text)")
                //task.modificationDate =
                //self.dateLabel
                
            }
        }
    }
    
    // Saves the task
    func saveTask() {
        if let editedTask = editedTask, taskTextField = taskTextField {
            
            let realm = Realm()
            
            println("This is edited task modification date \(editedTask.modificationDate)")
            

            realm.write() {
                if ((editedTask.taskTitle != self.taskTextField.text) ||
                    (editedTask.badge != self.badge) ||
                    (editedTask.modificationDate != self.dateLabel.text)){
                        
                        
                        // If the modification date is nothing, then keep it that way
                        if (editedTask.modificationDate != "") {
                            editedTask.modificationDate = self.dateLabel.text!
                        }
                        //println("THIS IS DATELABEL \(self.dateLabel)")
                        editedTask.taskTitle = self.taskTextField.text
                        // Saves the badge as the editedTask.badge passed from TaskVC
                        editedTask.badge = self.editedTask!.badge
                        
//                        if (self.orderingDate != nil) {
//                            newTask.orderingDate = self.orderingDate!
//                        }
                        
                        self.creationDate = NSDate()
                        
                        var dateFormatter = NSDateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss zzz"
                        
                        self.creationDateString = dateFormatter.stringFromDate(self.creationDate!)
                        
                        editedTask.creationDateString = self.creationDateString
                        
                        println("CREATIONDATESTRING OF EDITED TASK IS \(self.creationDateString)")
                        
                        
                } else {
                    println("nothing has changed")
                }
            }
        }
    }
    
    func scheduleNotification() {
        var localNotification: UILocalNotification = UILocalNotification()
        localNotification.fireDate = self.orderingDate
        localNotification.alertBody = "\(editedTask!.taskTitle) is due!"
        localNotification.alertAction = "see the task"
        localNotification.timeZone = NSTimeZone.localTimeZone()
        localNotification.soundName = UILocalNotificationDefaultSoundName
        localNotification.alertLaunchImage = "badgeHome"
        localNotification.userInfo = ["objectID" : editedTask!.creationDateString]
        println("userinfo dict is \(localNotification.userInfo)")
        localNotification.applicationIconBadgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber + 1
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        //println("NOTIFICATION SCHEDULED FOR \(self.orderingDate)")
        println("schedulenotification called")
    }

    
    @IBAction func selectDateAction(sender: AnyObject) {
        
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d"
        
    }
    
    @IBAction func backToEditFromChangeBadge(segue: UIStoryboardSegue) {
        if let identifier = segue.identifier {
            
            let realm = Realm()
            
            switch identifier {
            case "exitFromChangeBadge":
                println("exit from change badge")
                
            case "saveFromChangeBadge":
                println("save from change badge")
                
                let badgeSaveVC = segue.sourceViewController as! ChangeBadgeViewController
                
                // Sets the new badge as the badge selected from ChangeBadgeVC
                realm.write() {
                    self.editedTask!.badge = badgeSaveVC.badge
                }
                
            default:
                println("failed")
            }
        }
    }
    
    @IBAction func backFromCalendar(segue: UIStoryboardSegue) {
        if let identifier = segue.identifier {
            
            let realm = Realm()
            
            switch identifier {
            case "exitFromCalendar":
                println("exit from calendar")
                
            case "saveFromCalendar":
                println("save form calendar")
                //                dateLabel.text = self.editedTask!.modificationDate
                
                // Sets the string to be the new date
                realm.write() {
                    self.editedTask?.modificationDate = self.date
                }
                println(self.editedTask?.modificationDate)
                //println(dateLabel.text!)
                
                
                // Sets calendar date to be numDate
                calendarDateLabel.text = numDateLabel
                
            default:
                println("hi")
            }
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if (identifier == "saveFromEdit") {
            
            if (taskTextField.text.isEmpty) {
                
                println("EMPTY")
                // Show a popup alert!
                let emptyTextFieldAlertView = SCLAlertView()
                
                // The ok button
                emptyTextFieldAlertView.addButton("Ok") {
                    
                    // Closes the alertView
                    emptyTextFieldAlertView.close()
                    
                    self.taskTextField.becomeFirstResponder()
                }
                
                // This is what the type of popup the alert will show
                emptyTextFieldAlertView.showError("No Text", subTitle: "Please Enter Text In The Field")
                
                return false
                
            } else {
                
                //println("edited task modification \(editedTask?.modificationDate)")
                
                saveTask()
                
                // Schedules the notification
                scheduleNotification()
                
                 println("THE SCHEDULED NOTIFICATIONS \(UIApplication.sharedApplication().scheduledLocalNotifications)")
                
                return true
            }
        }
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "tapOnBadge") {
            let targetVC = segue.destinationViewController as! ChangeBadgeViewController
            targetVC.addButtonColor = self.addButtonColor
        } else if (segue.identifier == "goToCalendarFromEdit") {
            let targetVC = segue.destinationViewController as! CalendarViewController
            targetVC.addButtonColor = self.addButtonColor
        }
    }
    
    // Hides keyboard when you press done the view controller ends
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        taskTextField.resignFirstResponder()
        // call segue
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // println(self.editedTask!.modificationDate)
        // Checks to see if the due date is empty
        
        //calendar.selectedDate = showSelectedDate
        
        // Set delegate for uitextview
        taskTextField.delegate = self
        
        
        
        // Sticks keyboard so that you can never hide it
        
        calendarDateLabel.text = ""
        dateLabel.text = "Set Date"
        //println(self.date)
        // Changes the calendar flow to vertical
        //calendar.flow = .Vertical
        
        //taskTextField.delegate = self
        taskTextField.returnKeyType = UIReturnKeyType.Default
        
        // Initializes the navigation buttons
        let leftNavigation = self.navigationItem.leftBarButtonItem
        let rightNavigation = self.navigationItem.rightBarButtonItem
        
        // Colors the nav bar items
        
        if (addButtonColor == "") {
            leftNavigation?.tintColor = UIColor.whiteColor()
            rightNavigation?.tintColor = UIColor.whiteColor()
        }
        
        if (editButtonImage == "addPurple") {
            editImage.image = UIImage(named: "editPurple")
            
        } else if (editButtonImage == "addTurquoise") {
            editImage.image = UIImage(named: "editTurquoise")
            
            
        } else if (editButtonImage == "addRed") {
            editImage.image = UIImage(named: "editRed")
        } else if (editButtonImage == "addBlue") {
            editImage.image = UIImage(named: "editBlue")
            
        } else {
            editImage.image = UIImage(named: "editDark")
        }
        
        //println(editButtonImage)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // Hides keyboard whenever you tap outside the keyboard
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        displayTask(editedTask)
        displayBadge(editedTask)
        displayDate(editedTask)
        
        // keyboard pops up right away
        taskTextField.becomeFirstResponder()
        
        // Displays the badge image of the selectedTask
        badgeImage.image = UIImage(named: arrayConstants.cellImagesUnselected[editedTask!.badge])
    }
}

//extension EditTaskViewController: FSCalendarDataSource {
//
//
//    //    func calendar(calendar: FSCalendar!, hasEventForDate date: NSDate!) -> Bool {
//    //        return true
//    //    }
//
//}
//
//extension EditTaskViewController: FSCalendarDelegate {
//
//    func calendarCurrentMonthDidChange(calendar: FSCalendar!) {
//
//        // If the calendar changes month, then hide textfield
//        taskTextField.resignFirstResponder()
//
//    }
//
//
//    func tomorrowFlag() {
//        var tomorrowFlag: Bool = true
//
//        //        if (self.dateLabel.text == "Tomorrow") {
//        //            tomorrowFlag = false
//        //            tomorrowInt = 1
//        //        } else {
//        //            tomorrowFlag = true
//        //        }
//        //
//        //        if compareTodayDateString == comparePickedDateString {
//        //            self.dateLabel.text = "Today"
//        //        } else if tomorrowInt > todayInt && tomorrowFlag == true {
//        //            self.dateLabel.text = "Tomorrow"
//        //            tomorrowFlag = false
//        //        }
//        //
//        //        if ((tomorrowInt > todayInt) && (tomorrowFlag == false)) {
//        //            self.dateLabel.text = "Due \(dateString)"
//        //        } else
//        //    }
//
//    }
//
//    func calendar(calendar: FSCalendar!, didSelectDate date: NSDate!) {
//
//        // Gets rid of todays date circle
//        calendar.appearance.todayColor = UIColor.clearColor()
//        calendar.appearance.titleTodayColor = calendar.appearance.titleDefaultColor;
//        calendar.appearance.subtitleTodayColor = calendar.appearance.subtitleDefaultColor;
//
//        // Hides the keyboard when a date is selected
//        taskTextField.resignFirstResponder()
//
//        var tomorrowFlag: Bool = true
//
//        // date = the date which is picked and todays date is todays date
//        let todaysDate = NSDate()
//
//        // Sets the format for the date which is picked
//        var dateFormatter = NSDateFormatter()
//        var secondDateFormatter = NSDateFormatter()
//        //dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle
//        //dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
//        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        secondDateFormatter.dateFormat = "EEEE, MMMM dd"
//
//        dateFormatter.timeZone = NSTimeZone.defaultTimeZone()
//
//        // The proper date, but at 12:00:00 AM each day
//        var dateString = secondDateFormatter.stringFromDate(date)
//        var longDateString = dateFormatter.stringFromDate(date)
//        // The local date plus correct time
//        var localTimeDate = secondDateFormatter.stringFromDate(todaysDate)
//        var longLocalTimeDate = dateFormatter.stringFromDate(todaysDate)
//        // these var gets the string of the dates.
////        var pickedDateString = date.description
////        var todayDateString = localTimeDate
////
////        // Gives tomorrows date
////        var tomorrow = localTimeDate.dateByAddingTimeInterval(24 * 60 * 60)
////        var tomorrowDateString = tomorrow.description
////        //println(tomorrowDateString)
////
////        // The date for today in string
//        var compareTodayDateString = localTimeDate.substringToIndex(advance(localTimeDate.startIndex, 15))
////        //println(compareTodayDateString)
////
////        // The date which has been picked in string
//        var comparePickedDateString = dateString.substringToIndex(advance(dateString.startIndex, 15))
////
////        // The date for tomorrow in string
////        var frontTomorrowDateString = tomorrowDateString.substringToIndex(advance(tomorrowDateString.startIndex, 10))
//
////        // string to NSDate
////        dateFormatter.dateFormat = "EEEE MMMM d, YYYY"
////        localTimeDate = dateFormatter.stringFromDate(date)
////        dateFormatter.release()
//        var dateFromString = dateFormatter.dateFromString(longDateString)
//        var todayDateFromString = dateFormatter.dateFromString(longLocalTimeDate)
//
////        println(dateFromString!)
////        println(todayDateFromString!)
//
//        if (dateString == localTimeDate) {
//            dateLabel.text = "Due Today"
//            //showSelectedDate = todayDateFromString
//            //println(showSelectedDate)
//        } else {
//            dateLabel.text = "Due \(dateString)"
//            //showSelectedDate = dateFromString
//            //println(showSelectedDate)
//        }
//    }

