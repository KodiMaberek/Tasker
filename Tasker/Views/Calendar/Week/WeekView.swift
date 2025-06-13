//
//  WeekView.swift
//  Tasker
//
//  Created by Rodion Akhmedov on 4/11/25.
//

import SwiftUI

struct WeekView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State private var vm = WeekVM()
    
    let shape = UnevenRoundedRectangle(
        topLeadingRadius: 16,
        bottomLeadingRadius: 33,
        bottomTrailingRadius: 33,
        topTrailingRadius: 16,
        style: .circular
    )
    
    var body: some View {
        VStack {
            ZStack {
                HStack {
                    ForEach(1..<8) { index in
                        if vm.isSelectedDayOfWeek(index) {
                            shape
                                .fill(Color.labelTertiary.opacity(colorScheme == .dark ? 0.08 : 0.04))
                                .frame(maxWidth: .infinity)
                        } else {
                            Color.clear.frame(maxWidth: .infinity)
                        }
                    }
                }
                
                VStack {
                    HStack {
                        ForEach(vm.orderedWeekdaySymbols(), id: \.self) { symbol in
                            Text(symbol)
                                .foregroundStyle(Color.labelSecondary.opacity(0.8))
                                .frame(maxWidth: .infinity)
                        }
                    }
                    DayOfWeeksView()
                }
            }
            .frame(height: 84)
            
            TodayButton()
                .padding(.top, 8)
        }
        .padding(.bottom, 2)
        .animation(.default, value: vm.indexForWeek)
        .animation(.default, value: vm.selectedDate)
        .sensoryFeedback(.impact, trigger: vm.selectedDate)
        .sensoryFeedback(.levelChange, trigger: vm.indexForWeek)
    }
    
    @ViewBuilder
    private func DayOfWeeksView() -> some View {
        TabView(selection: $vm.dateManager.indexForWeek) {
            ForEach(vm.weeks) { week in
                HStack {
                    ForEach(week.date, id: \.self) { day in
                        Button {
                            vm.selectedDateButtonTapped(day)
                        } label: {
                            ZStack {
                                SegmentedCircleView(date: day)
                                    .frame(width: 40, height: 40)
                                
                                Text("\(day, format: .dateTime.day())")
                                    .font(.system(size: 17, weight: vm.calendar.isDateInToday(day) ? .semibold : .regular, design: .default))
                                    .foregroundStyle(!vm.calendar.isDateInToday(day) ? Color.quaternary.opacity(0.4) : Color.primary)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
            }
        }
        .animation(.spring(response: 0.2, dampingFraction: 1.8, blendDuration: 0), value: vm.indexForWeek)
        .frame(height: 36)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
    }
    
    @ViewBuilder
    private func TodayButton() -> some View {
        Button {
            vm.backToTodayButtonTapped()
        } label: {
            HStack {
                if vm.selectedDayIsToday() {
                    Image(systemName: "arrow.uturn.backward")
                        .foregroundStyle(Color.labelSecondary.opacity(0.8))
                }
                
                Text(vm.dateToString())
                    .foregroundStyle(Color.labelSecondary.opacity(0.8))
            }
            .padding(.vertical, 7)
            .padding(.horizontal, 14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        Color.labelTertiary.opacity(colorScheme == .dark ? 0.08 : 0.04)
                    )
            )
        }
    }
}

#Preview {
    WeekView()
}
