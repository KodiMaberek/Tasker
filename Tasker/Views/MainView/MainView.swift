//
//  MainView.swift
//  Tasker
//
//  Created by Rodion Akhmedov on 4/11/25.
//

import SwiftUI

struct MainView: View {
    
    @State private var vm = MainVM()
    
    var body: some View {
        NavigationStack {
            VStack {
                WeekView()
                
                Spacer()
                
                RecordButton(isRecording: $vm.isRecording, progress: vm.progress, countOfSec: vm.currentlyTime, animationAmount: vm.decibelLvl) {
                    Task {
                        try? await vm.startAfterChek()
                    }
                }
                .padding(.bottom, 45)
            }
            .ignoresSafeArea(.keyboard)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        
                    } label: {
                        Image(systemName: "calendar")
                            .foregroundStyle(elementColor.hexColor())
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    TextField("", text: $vm.textForYourSelf)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        
                    } label: {
                        Image(systemName: "person.circle")
                            .foregroundStyle(elementColor.hexColor())
                    }
                }
            }
        }
    }
}

#Preview {
    MainView()
}
