//
//  MainVM.swift
//  Tasker
//
//  Created by Rodion Akhmedov on 4/11/25.
//

import Foundation
import SwiftUI

@MainActor
@Observable
final class MainVM {
    @ObservationIgnored
    @AppStorage("textForYourSelf", store: .standard) var textForYourSelf = "Write your title 🎯"
    
    //MARK: - Depencies
    let casManager: CASManagerProtocol
    let recordPermission: PermissionProtocol
    let recordManager: RecordingProtocol
    let playerManager: PlayerProtocol
    let dateManager: DateManagerProtocol
    
    //MARK: - Model
    var model: MainModel?
    
    //MARK: - UI States
    var isRecording = false
    var showDetailsScreen = false
    var alert: Alert?
    
    //MARK: Copmputed properties
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
        casManager = CASManager()
        recordPermission = PermissionManager()
        recordManager = RecordManager()
        playerManager = PlayerManager()
        dateManager = DateManager.shared
    }
    
    func startAfterChek() async throws {
        
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
    
    func stopAfterCheck(_ newValue: Double?) async {
        guard newValue ?? 0 >= 15.0 else {
            return
        }
        
        stopRecord()
    }
    
    func startRecord() async {
        isRecording = true
        await recordManager.startRecording()
    }
    
    func stopRecord() {
        var hashOfAudio: String?
        
        if isRecording {
            isRecording = false
            
            if let audioURLString = recordManager.stopRecording() {
                hashOfAudio = casManager.saveAudio(url: audioURLString)
            }
        }
        model = MainModel.initial(TaskModel(id: UUID().uuidString, title: "", info: "", audio: hashOfAudio, notificationDate: dateManager.getDefaultNotificationTime().timeIntervalSince1970))
        
        recordManager.clearFileFromDirectory()
    }
}
