//
//  PlayerManagerProtocol.swift
//  Tasker
//
//  Created by Rodion Akhmedov on 4/11/25.
//

import Foundation

protocol PlayerManagerProtocol {
    var isPlaying: Bool { get set }
    var task: TaskModel? { get set }
    var currentTime: TimeInterval { get set }
    var totalTime: TimeInterval { get set }
    
    func playAudioFromData(_ audio: Data, task: TaskModel) async
    func stopToPlay()
    func seekAudio(_ time: TimeInterval)
}
