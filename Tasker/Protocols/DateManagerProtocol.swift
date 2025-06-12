//
//  DateManagerProtocol.swift
//  Tasker
//
//  Created by Rodion Akhmedov on 4/11/25.
//

import Combine
import Foundation

protocol DateManagerProtocol {
    var calendar: Calendar { get }
    var today: Date { get set }
    var selectedDate: Date { get set }
    var indexForWeek: Int { get set }
    var allWeeks: [PeriodModel] { get set }
    var allMonths: [PeriodModel] { get set }
    
    func initializeWeek()
    func startOfWeek(for date: Date) -> Date
    func selectedDateChange(_ day: Date)
    func appendWeeksForward()
    func prependWeeksBackward()
    func dateToString(date: Date, format: String?) -> String
    func getDefaultNotificationTime() -> Date
    /// Reset selected day to current current
    func backToToday()
    /// Next day after swipe to left
    func addOneDay()
    /// Previous day after swip to right
    func subtractOneDay()
}
