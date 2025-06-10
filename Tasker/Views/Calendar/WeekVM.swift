//
//  WeekVM.swift
//  Tasker
//
//  Created by Rodion Akhmedov on 4/11/25.
//

import SwiftUI

@Observable
final class WeekVM {
    var dateManager: DateManagerProtocol
    
    var calendar: Calendar {
        dateManager.calendar
    }
    
    var selectedDate: Date {
        dateManager.selectedDate
    }
    
    var today: Date {
        dateManager.today
    }
    
    var weeks: [PeriodModel] {
        dateManager.allWeeks
    }
    
    var selectedWeekDay: Int {
        calendar.component(.weekday, from: dateManager.selectedDate)
    }
    
    init() {
        dateManager = DateManager.shared
    }
    
    var indexForWeek: Int {
        dateManager.indexForWeek
    }
    
    func selectedDateButtonTapped(_ day: Date) {
        dateManager.selectedDate = day
    }
    
    func backToTodayButtonTapped() {
        dateManager.backToTodayButtonTapped()
    }
    
    func isToday(_ date: Date) -> Bool {
        calendar.isDate(date, inSameDayAs: dateManager.selectedDate)
    }
    
    func selectedDayIsToday() -> Bool {
        !calendar.isDate(selectedDate, inSameDayAs: today)
    }
    
    func isSelectedDayOfWeek(_ index: Int) -> Bool {
        return index == selectedWeekDay
    }
    
    func orderedWeekdaySymbols() -> [String] {
        let weekdaySymbols = calendar.shortWeekdaySymbols
        let firstWeekday = calendar.firstWeekday - 1
        
        let orderedSymbols = Array(weekdaySymbols[firstWeekday..<weekdaySymbols.count] + weekdaySymbols[0..<firstWeekday])
        
        return orderedSymbols
    }
    
    func dateToString() -> String {
        dateManager.dateToString(date: selectedDate, format: nil)
    }
}
