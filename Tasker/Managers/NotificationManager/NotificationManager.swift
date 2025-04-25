//
//  NotificationManager.swift
//  Tasker
//
//  Created by Rodion Akhmedov on 4/24/25.
//

import Foundation
import UserNotifications

@Observable
final class NotificationManager {
    
    let notificationContent = UNMutableNotificationContent()
    let notificationCenter = UNUserNotificationCenter.current()
    let authorizationOption: UNAuthorizationOptions = [.alert, .badge, .carPlay, .sound, .criticalAlert, .providesAppNotificationSettings]
    
    var granted = false
    
    let calendar = Calendar.current
    
    func notif() async {
        notificationContent.title = "Background push"
        notificationContent.body = "Tasker was updated"
        notificationContent.sound = .default
        
        let triger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: notificationContent, trigger: triger)
        do {
            try await notificationCenter.add(request)
        } catch {
            
        }
    }
    //MARK: Notification body
    func createNotification(_ task: TaskModel) {
        
        notificationContent.title = task.title
        notificationContent.body = task.info
        
        if task.voiceMode == false {
            notificationContent.sound = .default
        } else {
            notificationContent.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: String("\(task.audio)")))
        }
        
        var date = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: Date(timeIntervalSince1970: task.notificationDate ?? 0))
        var trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: false)
        
        
        switch task.repeatTask {
        case .never:
            trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: false)
        case .daily:
            date = calendar.dateComponents([.hour, .minute], from: Date(timeIntervalSince1970: task.notificationDate ?? 0))
            trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        case .weekly:
            date = calendar.dateComponents([.weekday, .hour, .minute], from: Date(timeIntervalSince1970: task.notificationDate ?? 0))
            trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        case .monthly:
            date = calendar.dateComponents([.day, .hour, .minute], from: Date(timeIntervalSince1970: task.notificationDate ?? 0))
            trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        case .yearly:
            date = calendar.dateComponents([.month, .day, .hour, .minute], from: Date(timeIntervalSince1970: task.notificationDate ?? 0))
            trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        case .dayOfWeek:
            date = calendar.dateComponents([.weekday, .hour, .minute], from: Date(timeIntervalSince1970: task.notificationDate ?? 0))
            trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        }
        
        let request = UNNotificationRequest(identifier: task.uniqueID , content: notificationContent, trigger: trigger)
        notificationCenter.add(request)
        print(request)
    }
    
    func removeEvent(for task: TaskModel) async {
        await deleteNotification(for: task.uniqueID)
    }
    
    func removeEvents(for tasks: [TaskModel]) async {
        for task in tasks {
            await deleteNotification(for: task.uniqueID)
        }
    }
    
    func removeAllEvents() async {
        notificationCenter.removeAllDeliveredNotifications()
        notificationCenter.removeAllPendingNotificationRequests()
    }
    private func deleteNotification(for id: String) async  {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [id])
    }
    
    //MARK: Permission for notification
    func checkPermission() async throws -> Bool {
        do {
            let authorizationGranted = try await notificationCenter.requestAuthorization(options: authorizationOption)
            
            return authorizationGranted
        } catch {
            throw error
        }
    }
}

