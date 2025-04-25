//
//  TaskRowVM.swift
//  Tasker
//
//  Created by Rodion Akhmedov on 4/14/25.
//

import Foundation

@Observable
final class TaskRowVM {
    var playerManager: PlayerProtocol
    var dateManager: DateProtocol
    
    var playingTask: TaskModel?
    
    var playing: Bool {
        playerManager.isPlaying
    }
    
    init() {
        playerManager = PlayerManager()
        dateManager = DateManager()
    }
    
    func checkMarkTapped(model: TaskModel) {
        model.done?.completedFor?.append(dateManager.selectedDate.timeIntervalSince1970)
    }
    
    func playButtonTapped(task: TaskModel) {
        if !playing {
            playerManager.playAudioFromData(task)
            playingTask = task
        } else {
            playerManager.stopToPlay()
            playingTask = nil
        }
    }
}
