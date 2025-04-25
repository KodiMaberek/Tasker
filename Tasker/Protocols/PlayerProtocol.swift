//
//  PlayerProtocol.swift
//  Tasker
//
//  Created by Rodion Akhmedov on 4/11/25.
//

import Foundation

protocol PlayerProtocol {
    var isPlaying: Bool { get set }
    
    func playAudioFromData(_ task: TaskModel)
    func stopToPlay()
    func checkIsPlaying()
}
