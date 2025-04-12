//
//  RecordButton.swift
//  Tasker
//
//  Created by Rodion Akhmedov on 4/11/25.
//

import SwiftUI
import CoreHaptics

struct RecordButton: View {
    @State private var engine: CHHapticEngine?
    
    @Binding var isRecording: Bool
    
    var progress: Double
    var countOfSec: Double
    var animationAmount: Float
    
    var action: () -> Void
    
    var body: some View {
        Button {
            action()
            prepareHaptics()
        } label: {
            if isRecording {
                StopRecording()
                    .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.5), trigger: animationAmount)
            } else {
                StartRecording()
            }
        }
    }
    
    @ViewBuilder
    private func StartRecording() -> some View {
        Image(systemName: "plus")
            .font(.system(size: 42))
            .foregroundStyle(elementColor.hexColor())
            .frame(width: 64, height: 64)
            .padding(13)
            .background(
                Circle()
                    .fill(
                        .white
                    )
                    .shadow(color: elementColor.hexColor(), radius: 3)
            )
    }
    
    @ViewBuilder
    private func StopRecording() -> some View {
        Image(systemName: "pause.fill")
            .font(.system(size: 42))
            .foregroundStyle(elementColor.hexColor())
            .frame(width: 54, height: 54)
            .padding(13)
            .background(
                ZStack {
                    Circle()
                        .stroke(Color.tertiary.opacity(0.04), style: StrokeStyle(lineWidth: 3.0, lineCap: .round, lineJoin: .round))
                    Circle()
                        .trim(from: 0, to: CGFloat(progress))
                        .stroke(elementColor.hexColor(), style: StrokeStyle(lineWidth: 3.0, lineCap: .round, lineJoin: .round))
                        .rotationEffect(Angle(degrees: 270))
                        .animation(.easeInOut(duration: 0.1), value: progress)
                        .overlay {
                            if animationAmount > 0.8 {
                                AnimationView()
                            }
                        }
                        .animation(.easeInOut(duration: 0.25), value: animationAmount)
                        .animation(.spring, value: progress)
                }
            )
    }
    
    @ViewBuilder
    private func AnimationView() -> some View {
        ZStack {
            Circle()
                .stroke(elementColor.hexColor().opacity(0.4), lineWidth: 0.7)
                .scaleEffect(CGFloat(animationAmount) + 0.8)
                .animation(.easeOut(duration: 0.3), value: animationAmount)
                .shadow(color: elementColor.hexColor(), radius: 3)
            
            Circle()
                .stroke(elementColor.hexColor().opacity(0.6), lineWidth: 1.0)
                .scaleEffect(CGFloat(animationAmount) + 0.55)
                .animation(.easeOut(duration: 0.3).delay(0.05), value: animationAmount)
                .shadow(color: elementColor.hexColor(), radius: 2)
            
            Circle()
                .stroke(elementColor.hexColor().opacity(0.8), lineWidth: 1.5)
                .scaleEffect(CGFloat(animationAmount) + 0.3)
                .animation(.easeOut(duration: 0.3).delay(0.1), value: animationAmount)
                .shadow(color: elementColor.hexColor(), radius: 1)
        }
    }
    
    func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("There was an error creating the engine: \(error.localizedDescription)")
        }
    }
}

#Preview {
    RecordButton(isRecording: .constant(false), progress: 0.7, countOfSec: 23.1, animationAmount: 1.1, action: {})
}
