//
//  DateManager.swift
//  Tasker
//
//  Created by Rodion Akhmedov on 4/11/25.
//

import Foundation
import SwiftUI

@Observable
final class DateManager: DateProtocol {
    @ObservationIgnored
    @AppStorage("calendar", store: .standard) var firstDay = 1
    
    var calendar = Calendar.current
    
    var today = Date()
    var selectedDate = Date()
    
    var allWeeks: [PeriodModel] = []
    var allMonths: [PeriodModel] = []
    
    init() {
        selectedDate = today
        calendar.firstWeekday = firstDay
        initializeWeek()
    }
    
    //MARK: - Logic for week
    func initializeWeek() {
        allWeeks.removeAll()
        //MARK: Previous 4 weeks
        for i in (1...4).reversed() {
            let week = calendar.date(byAdding: .weekOfYear, value: -i, to: startOfWeek(for: selectedDate))!
            let newWeek = generateWeek(for: week)
            allWeeks.append(PeriodModel(id: -i, date: newWeek))
        }
        
        let currentWeekStart = startOfWeek(for: selectedDate)
        allWeeks.append(PeriodModel(id: 1, date: generateWeek(for: currentWeekStart)))
        
        var idNumber = 2
        for i in 1...4 {
            let week = calendar.date(byAdding: .weekOfYear, value: i, to: startOfWeek(for: selectedDate))!
            let newWeek = generateWeek(for: week)
            allWeeks.append(PeriodModel(id: idNumber, date: newWeek))
            idNumber += 1
        }
    }
    
    func startOfWeek(for date: Date) -> Date {
        calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)) ?? date
    }
    
    private func generateWeek(for date: Date) -> [Date] {
        let startOfWeek = startOfWeek(for: date)
        return (0..<7).map { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek)!
        }
    }
    
    func appendWeeksForward() {
        guard let lastWeekStart = allWeeks.last?.date.first else { return }
        for i in 1...24 {
            let weekStart = calendar.date(byAdding: .weekOfYear, value: i, to: lastWeekStart)!
            let newWeek = generateWeek(for: weekStart)
            allWeeks.append(PeriodModel(id: allWeeks.last!.id + 1, date: newWeek))
        }
    }
    
    func prependWeeksBackward() {
        guard let firstWeekStart = allWeeks.first?.date.first else { return }
        for i in (1...24) {
            let weekStart = calendar.date(byAdding: .weekOfYear, value: -i, to: firstWeekStart)!
            let newWeek = generateWeek(for: weekStart)
            allWeeks.insert(PeriodModel(id: allWeeks.first!.id - 1, date: newWeek), at: 0)
        }
    }
    
    func dateToString(date: Date, format: String? = nil) -> String {
        if let format = format {
            let formatter = DateFormatter()
            formatter.dateFormat = format
            formatter.locale = Locale.current
            return formatter.string(from: date)
        }
        
        let weekday = date.formatted(.dateTime.weekday(.wide).locale(Locale.current))
        let dateString = date.formatted(.dateTime.day().month(.wide).year().locale(Locale.current))
        
        return "\(weekday) - \(dateString)"
    }
    
    func getDefaultNotificationTime() -> Date {
        let calendar = Calendar.current
        let now = Date()
        
        var morningComponents = calendar.dateComponents([.year, .month, .day], from: now)
        morningComponents.hour = 9
        morningComponents.minute = 0
        morningComponents.second = 0
        let morningTime = calendar.date(from: morningComponents)!
        
        var eveningComponents = calendar.dateComponents([.year, .month, .day], from: now)
        eveningComponents.hour = 21
        eveningComponents.minute = 0
        eveningComponents.second = 0
        let eveningTime = calendar.date(from: eveningComponents)!
        
        let currentHour = calendar.component(.hour, from: now)
        
        if currentHour >= 21 {
            return calendar.date(byAdding: .day, value: 1, to: morningTime)!
        } else if currentHour >= 9 {
            let diffToMorning = abs(now.timeIntervalSince(morningTime))
            let diffToEvening = abs(now.timeIntervalSince(eveningTime))
            
            if diffToMorning <= diffToEvening {
                return morningTime
            } else {
                return eveningTime
            }
        } else {
            return morningTime
        }
    }
}
