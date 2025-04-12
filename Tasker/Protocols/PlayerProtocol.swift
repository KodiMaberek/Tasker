//
//  PlayerProtocol.swift
//  Tasker
//
//  Created by Rodion Akhmedov on 4/11/25.
//

import Foundation

protocol PlayerProtocol {
    var isPlaying: Bool { get set }
    
    func playAudioFromData(_ audioData: Data)
    func stopToPlay()
    func checkIsPlaying()
}
