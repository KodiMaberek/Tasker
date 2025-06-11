//
//  DateManager.swift
//  Tasker
//
//  Created by Rodion Akhmedov on 4/11/25.
//

import Foundation
import SwiftUI

@Observable
final class DateManager: DateManagerProtocol {
    @ObservationIgnored
    @AppStorage("calendar", store: .standard) var firstDay = 1
    
    static var shared = DateManager()
    
    var calendar = Calendar.current
    
    var today = Date()
    var selectedDate = Date()
    
    var allWeeks: [PeriodModel] = []
    var allMonths: [PeriodModel] = []
    
    var selectedWeekDay: Int {
        calendar.component(.weekday, from: selectedDate)
    }
    
    @ObservationIgnored
    var indexForWeek = 1 {
        didSet {
            Task { @MainActor in
                try await Task.sleep(nanoseconds: 350000000)
                let weeksDate = allWeeks.first(where: { $0.id == indexForWeek})!.date
                if let sameWeekDay = weeksDate.first(where: {
                    calendar.component(.weekday, from: $0) == selectedWeekDay
                }) {
                    selectedDate = sameWeekDay
                } else {
                    selectedDate = allWeeks[1].date.first!
                }
            }
        }
    }
    
    init() {
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
        let now = selectedDate
        
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
    
    func addOneDay() {
        let currentDate = selectedDate
        let newDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        
        // Проверка на выход за пределы
        if let lastDate = allWeeks.last?.date.last, newDate > lastDate {
            appendWeeksForward()
        }
        
        selectedDate = newDate
        
        let currentWeek = calendar.component(.weekOfYear, from: currentDate)
        let newWeek = calendar.component(.weekOfYear, from: newDate)
        
        if newWeek != currentWeek {
            updateWeekIndex(for: newDate)
        }
    }
    
    func subtractOneDay() {
        let currentDate = selectedDate
        let newDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
        
        if let firstDate = allWeeks.first?.date.first, newDate < firstDate {
            prependWeeksBackward()
        }
        
        selectedDate = newDate
        
        let currentWeek = calendar.component(.weekOfYear, from: currentDate)
        let newWeek = calendar.component(.weekOfYear, from: newDate)
        
        if newWeek != currentWeek {
            updateWeekIndex(for: newDate)
        }
    }
    
    
    func backToTodayButtonTapped() {
        selectedDate = today
        indexForWeek = 1
    }
    
    private func updateWeekIndex(for date: Date) {
        let newWeekStart = startOfWeek(for: date)
        
        if let newWeek = allWeeks.first(where: { startOfWeek(for: $0.date.first!) == newWeekStart }) {
            indexForWeek = newWeek.id
        } else {
            appendWeeksForward()
            prependWeeksBackward()
            
            if let refreshedWeek = allWeeks.first(where: { startOfWeek(for: $0.date.first!) == newWeekStart }) {
                indexForWeek = refreshedWeek.id
            }
        }
    }
    
}
