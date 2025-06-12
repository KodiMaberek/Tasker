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
    var manager: DependenceManagerProtocol?
    
    private var casManager: CASManagerProtocol {
        print("cas manager init")
        return manager?.casManager ?? CASManager()
    }
    
    private var recordPermission: PermissionProtocol {
        print("premission manager init")
        return manager?.permissionManager ?? PermissionManager()
    }
    
    private var recordManager: RecorderManagerProtocol {
        print("record manager init")
        return manager?.recorderManager ?? RecorderManager()
    }
    
    private var playerManager: PlayerManagerProtocol {
        print("player manager init")
        return manager?.playerManager ?? PlayerManager()
    }
    
    private var dateManager: DateManagerProtocol {
        print("date manager init")
        return manager?.dateManager ?? DateManager()
    }
    
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
    
    func onAppear(manager: DependenceManagerProtocol) {
        self.manager = manager
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
