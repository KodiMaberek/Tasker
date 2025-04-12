//
//  DateProtocol.swift
//  Tasker
//
//  Created by Rodion Akhmedov on 4/11/25.
//

import Foundation

protocol DateProtocol {
    var calendar: Calendar { get }
    var today: Date { get set }
    var selectedDate: Date { get set }
    var allWeeks: [PeriodModel] { get set }
    var allMonths: [PeriodModel] { get set }
    
    func initializeWeek()
    func startOfWeek(for date: Date) -> Date
    func appendWeeksForward()
    func prependWeeksBackward()
    func dateToString(date: Date, format: String?) -> String
}
