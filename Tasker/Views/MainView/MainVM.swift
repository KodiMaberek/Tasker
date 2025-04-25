//
//  MainVM.swift
//  Tasker
//
//  Created by Rodion Akhmedov on 4/11/25.
//

import Foundation
import SwiftUI

@Observable
final class MainVM {
    @ObservationIgnored
    @AppStorage("textForYourSelf", store: .standard) var textForYourSelf = "Write your title 🎯"
    
    var recordManager: RecordingProtocol
    var playerManager: PlayerProtocol
    var recordPermission: PermissionProtocol
    
    var isRecording = false
    var showDetailsScreen = false
    var soundData: Data?
    
    var alert: Alert?
    
    var currentlyTime: Double {
        recordManager.currentlyTime
    }
    
    var progress: Double {
        recordManager.progress
    }
    
    var decibelLvl: Float {
        recordManager.decibelLevel
    }
    
    init() {
        recordManager = RecordManager()
        playerManager = PlayerManager()
        recordPermission = PermissionManager()
    }
    
    func startAfterChek() async throws {
        if isRecording {
            await stopRecord()
        } else {
            playerManager.stopToPlay()
            
            do {
                try recordPermission.peremissionSessionForRecording()
                await startRecord()
            } catch let error as MicrophonePermission {
                switch error {
                case .silentError: return
                case .microphoneIsNotAvalible:
                    alert = error.showingAlert()
                }
            } catch let error as ErrorRecorder {
                switch error {
                case .cannotInterruptOthers, .cannotStartRecording, .insufficientPriority, .isBusy, .siriIsRecordign, .timeIsLimited:
                    alert = error.showingAlert()
                case .none:
                    return
                }
            }
        }
    }
    
    func stopAfterCheck(_ newValue: Double?) async {
        guard newValue ?? 0 >= 15 else {
            return
        }
        await stopRecord()
    }
    
    func startRecord() async {
        isRecording = true
        await recordManager.startRecording()
    }
    
    func stopRecord() async {
        do {
            await recordManager.stopRecording()
            isRecording = false
            showDetailsScreen = true
        } catch {
            print("Couldn't stop recording")
        }
    }
}
