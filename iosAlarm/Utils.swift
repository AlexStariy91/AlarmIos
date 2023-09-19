//
//  Utils.swift
//  iosAlarm
//
//  Created by Alexander Starodub on 19.07.2023.
//

import Foundation
import UserNotifications
import UIKit

class Utils: NSObject {
    static let shared = Utils()
    
    
    func checkPendingNotificationsAndSetAlarmIsOnProperty(_ notificationCenter: UNUserNotificationCenter, _ alarms: [Alarm]){
        notificationCenter.getPendingNotificationRequests { requests in
            if !alarms.isEmpty {
                for i in 0...alarms.count - 1 {
                    if requests.contains(where: { request in
                        request.identifier == alarms[i].id
                    }) || requests.contains(where: { request in
                        request.identifier.hasPrefix(alarms[i].id)
                    }){
                        alarms[i].alarmIsOn = true
                        SavedAlarms().saveAlarm(arrayOfAlarms: alarms)
                    } else {
                        alarms[i].alarmIsOn = false
                        SavedAlarms().saveAlarm(arrayOfAlarms: alarms)
                    }
                }
            }
        }
    }
    
     func showPendingNotifications(_ notificationCenter: UNUserNotificationCenter){
        notificationCenter.getPendingNotificationRequests(completionHandler: { requests in
            for req in requests{
                let nextTrigger = req.trigger as? UNCalendarNotificationTrigger
                let date = nextTrigger?.nextTriggerDate()
                let formatter = DateFormatter()
                formatter.locale = Locale.current
                formatter.dateStyle = .long
                formatter.timeStyle = .full
                guard let time = date else {return}
                let stringNextTrigger = formatter.string(from: time)
                print("Next alarm at: \(stringNextTrigger)")
            }
        })
    }
    
    func createSnoozeNotification(notificationCenter: UNUserNotificationCenter, respone: UNNotificationResponse){
        let identifier = respone.notification.request.identifier + "snooze"
        let content = respone.notification.request.content.mutableCopy() as! UNMutableNotificationContent
        content.title = "Snooze"
        content.body = "It's time to wake up!"
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5*60, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        notificationCenter.add(request,withCompletionHandler: { (errorObject) in
            if let error = errorObject {
                print("Error \(error.localizedDescription)")
            }
        })
        
    }
    
    func createNotification(datePicker: UIDatePicker?, alarm: Alarm, notificationCenter: UNUserNotificationCenter){
        var pickedTime = Date()
        if datePicker != nil {
            alarm.date = datePicker?.date
            pickedTime = datePicker!.date
        } else {
            pickedTime = alarm.date!
        }
        var calendar = Calendar.current
        calendar.locale = Locale.current
        let content = UNMutableNotificationContent()
        content.title = "Alarm"
        content.body = "It's time to wake up!"
        content.sound = UNNotificationSound(named: UNNotificationSoundName(alarm.sound + ".wav"))
        if alarm.snooze {
            setCategoryToNotification(notifiactionCenter: notificationCenter, snoozeIsOn: true, identifierOfCategory: "categoryWithSnooze", contentOfNotification: content)
        } else {
            setCategoryToNotification(notifiactionCenter: notificationCenter, snoozeIsOn: false, identifierOfCategory: "categoryWithoutSnooze", contentOfNotification: content)
        }
        if alarm.weekDays.isEmpty {
            deleteOldPendingNotifications(alarm: alarm, notificationCenter: notificationCenter)
            let singleAlarm = calendar.dateComponents([.hour, .minute], from: pickedTime)
            let trigger = UNCalendarNotificationTrigger(dateMatching: singleAlarm, repeats: false)
            let request = UNNotificationRequest(identifier: alarm.id, content: content, trigger: trigger)
            notificationCenter.add(request)
        } else {
            deleteOldPendingNotifications(alarm: alarm, notificationCenter: notificationCenter)
            alarm.weekDays.forEach { weekDay in
                var multipleAlarm = calendar.dateComponents([.hour, .minute], from: pickedTime)
                multipleAlarm.weekday = weekDay.rawValue
                let trigger = UNCalendarNotificationTrigger(dateMatching: multipleAlarm, repeats: true)
                let request = UNNotificationRequest(identifier: alarm.id + weekDay.fullDayName, content: content, trigger: trigger)
                notificationCenter.add(request)
            }
        }
    }
    
    private func setCategoryToNotification(notifiactionCenter: UNUserNotificationCenter, snoozeIsOn: Bool, identifierOfCategory: String, contentOfNotification: UNMutableNotificationContent){
        let stopAction = UNNotificationAction(identifier: "stopAction", title: "Stop")
        var actions = [stopAction]
        if snoozeIsOn {
           let snoozeAction = UNNotificationAction(identifier: "snoozeAction", title: "Repeat in 5 minutes")
            actions.insert(snoozeAction, at: 0)
        }
        let actionCategory = UNNotificationCategory(identifier: identifierOfCategory, actions: actions, intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: "It's time to wake up!", options: [.customDismissAction, .hiddenPreviewsShowSubtitle, .hiddenPreviewsShowTitle])
        contentOfNotification.categoryIdentifier = identifierOfCategory
        notifiactionCenter.setNotificationCategories([actionCategory])
    }
        
    func deleteOldPendingNotifications(alarm: Alarm, notificationCenter: UNUserNotificationCenter){
        var oldPendingNotificationsIdentifiers = [alarm.id]
        let arrayForAddingToRequestId = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "snooze"]
        arrayForAddingToRequestId.forEach { element in
            oldPendingNotificationsIdentifiers.append(alarm.id + element)
            
        }
        notificationCenter.removePendingNotificationRequests(withIdentifiers: oldPendingNotificationsIdentifiers)
    }
}
