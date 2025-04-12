//
//  ErrorRecorder.swift
//  Tasker
//
//  Created by Rodion Akhmedov on 4/11/25.
//

import Foundation
import SwiftUI

enum ErrorRecorder: Error {
    case timeIsLimited
    case isBusy
    case cannotInterruptOthers
    case siriIsRecordign
    case cannotStartRecording
    case insufficientPriority
    case none
    
    func showingAlert() -> Alert {
        switch self {
        case .timeIsLimited:
            Alert(title: Text("Recording has finished"), message: Text("Unfortunately we are currently unable to record task longer then 15 seconds."), dismissButton: .default(Text("OK")))
        case .isBusy:
            Alert(title: Text("Recording is unavailable"), message: Text("The microphone is currently busy, please stop use it and try again."), dismissButton: .default(Text("OK")))
        case .cannotInterruptOthers:
            Alert(title: Text("Cannot Interrupt Others"), message: Text("This operation cannot interrupt other processes. Please try again later."), dismissButton: .default(Text("OK")))
        case .siriIsRecordign:
            Alert(title: Text("Siri is Recording"), message: Text("Siri is currently recording. Please wait until Siri has finished."), dismissButton: .default(Text("OK")))
        case .cannotStartRecording:
            Alert(title: Text("Cannot start recording"), message: Text("Unable to start recording. Please try again later."), dismissButton: .default(Text("OK")))
        case .insufficientPriority:
            Alert(title: Text("Cannot start record"), message: Text("Please end the call to start recording."), dismissButton: .default(Text("OK")))
        case .none:
            fatalError()
        }
    }
}
