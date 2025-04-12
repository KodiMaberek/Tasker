//
//  PlayerManager.swift
//  Tasker
//
//  Created by Rodion Akhmedov on 4/11/25.
//

import AVFoundation
import Foundation

@Observable
final class PlayerManager: PlayerProtocol {
    var isPlaying = false
    private var player: AVAudioPlayer?
    
    func playAudioFromData(_ audioData: Data)  {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.allowAirPlay, .allowBluetooth, .allowBluetoothA2DP, .defaultToSpeaker, .duckOthers])
            try audioSession.overrideOutputAudioPort(.speaker)
            
            
            player = try AVAudioPlayer(data: audioData)
            player?.prepareToPlay()
            player?.play()
            isPlaying = player!.isPlaying
            checkIsPlaying()
        } catch {
            print("Couldn't play audio")
        }
    }
    
    func stopToPlay() {
        player?.stop()
        player = nil
        isPlaying = false
    }
    
    func checkIsPlaying() {
        _ = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if self.player?.isPlaying == false {
                self.isPlaying = false
            }
        }
    }
}
