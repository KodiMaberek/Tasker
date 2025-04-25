//
//  WeekView.swift
//  Tasker
//
//  Created by Rodion Akhmedov on 4/11/25.
//

import SwiftUI

//TODO: FIX Colors
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
                                .fill(Color.tertiary.opacity(colorScheme == .dark ? 0.08 : 0.04))
                                .frame(maxWidth: .infinity)
                        } else {
                            Color.clear.frame(maxWidth: .infinity)
                        }
                    }
                }
                
                VStack(spacing: 8) {
                    HStack {
                        ForEach(vm.orderedWeekdaySymbols(), id: \.self) { symbol in
                            Text(symbol)
                                .foregroundStyle(Color.secondary.opacity(0.8))
                                .frame(maxWidth: .infinity)
                        }
                    }
                    DayOfWeeksView()
                }
            }
            .frame(height: 84)
            
            TodayButton()
                .padding(.top, 10)
        }
        .animation(.default, value: vm.indexForWeek)
        .animation(.default, value: vm.selectedDate)
        .sensoryFeedback(.impact, trigger: vm.selectedDate)
        .sensoryFeedback(.levelChange, trigger: vm.indexForWeek)
    }
    
    @ViewBuilder
    private func DayOfWeeksView() -> some View {
        TabView(selection: $vm.indexForWeek) {
            ForEach(vm.weeks) { week in
                HStack {
                    ForEach(week.date, id: \.self) { day in
                        Button {
                            vm.selectedDateButtonTapped(day)
                        } label: {
                            Text("\(day, format: .dateTime.day())")
                                .animation(.bouncy)
                                .foregroundStyle(Color.quaternary.opacity(0.4))
                                .frame(maxWidth: .infinity)
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
                        .foregroundStyle(Color.tertiary.opacity(0.8))
                }
                
                Text(vm.dateToString())
                    .foregroundStyle(Color.secondary.opacity(0.8))
            }
            .padding(.vertical, 7)
            .padding(.horizontal, 14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        Color.tertiary.opacity(colorScheme == .dark ? 0.08 : 0.04)
                    )
            )
        }
    }
}

#Preview {
    WeekView()
}
