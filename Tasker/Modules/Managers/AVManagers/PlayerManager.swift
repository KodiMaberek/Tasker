//
//  PlayerManager.swift
//  Tasker
//
//  Created by Rodion Akhmedov on 4/11/25.
//

import AVFoundation
import Foundation
import Models

@Observable
final class PlayerManager: PlayerManagerProtocol, Sendable {
    
    let audioSession = AVAudioSession.sharedInstance()
    
    //MARK: Properties
    var isPlaying = false
    var task: TaskModel?
    
    //MARK: - Private properties
    private var player: AVAudioPlayer?
    private var audioURL: URL?
    private var playbackTimer: Timer?
    
    private var isSeeking = false
    private var seekTimer: Timer?
    
    var currentTime: TimeInterval = 0.0
    var totalTime: TimeInterval = 0.0
    
    func playAudioFromData(_ audio: Data, task: TaskModel) async {
        
        if task.audio != self.task?.audio {
            stopToPlay()
        }
        
        self.task = task
        
        do {
            try audioSession.setCategory(.playAndRecord, mode: .voiceChat, options: [.interruptSpokenAudioAndMixWithOthers, .allowAirPlay, .allowBluetooth, .allowBluetoothA2DP, .defaultToSpeaker, .duckOthers])
            try audioSession.overrideOutputAudioPort(.speaker)
            try audioSession.setActive(true)
            
            let audioURL = createTempAudioFileAsync(from: audio)
            
            do {
                if player == nil {
                    player = try AVAudioPlayer(contentsOf: audioURL)
                }
                player?.play()
                totalTime = player?.duration ?? 0.0
                isPlaying = player?.isPlaying ?? false
                await MainActor.run {
                    startPlaybackTimer()
                }
            } catch {
                print("Couldn't create player: \(error)")
            }
            
        } catch {
            print("Couldn't setup audio session: \(error)")
        }
        return
    }
    
    func pauseAudio() {
        print("pause")
        player?.pause()
    }
    
    func stopToPlay() {
        isPlaying = false
        player = nil
        player?.stop()
        stopPlaybackTimer()
        currentTime = 00
    }
    
    func seekAudio(_ time: TimeInterval) {
        guard let player = player else { return }
        
        isSeeking = true
        
        seekTimer?.invalidate()
        
        currentTime = time
        
        seekTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
            Task { @MainActor in
                let wasPlaying = player.isPlaying
                
                if wasPlaying {
                    player.pause()
                }
                
                player.currentTime = time
                
                if wasPlaying {
                    player.play()
                }
                
                self.isSeeking = false
                self.seekTimer = nil
            }
        }
    }
    
    func returnTotalTime(_ audio: Data, task: TaskModel) -> Double {
        self.task = task
        
        let audioURL = createTempAudioFileAsync(from: audio)
        var duration: TimeInterval = 0
        
        do {
            if player == nil {
                player = try AVAudioPlayer(contentsOf: audioURL)
            }
            
            duration = player?.duration ?? 00
        } catch {
            print("Cannot create avAudioPlayer")
        }
        return duration
    }
    
    private func startPlaybackTimer() {
        stopPlaybackTimer()
        
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self, let player = self.player else { return }
                
                self.currentTime = player.currentTime
                
                if !player.isPlaying {
                    self.isPlaying = false
                    self.stopPlaybackTimer()
                }
            }
        }
    }
    
    private func stopPlaybackTimer() {
        playbackTimer?.invalidate()
        playbackTimer = nil
    }
    
    private func createTempAudioFileAsync(from data: Data) -> URL {
        let tempDirectory = FileManager.default.temporaryDirectory
        var name: String
        
        if let task = task, let audio = task.audio {
            name = audio
        } else {
            name = UUID().uuidString
        }
        
        let fileName = "\(name).wav"
        let tempURL = tempDirectory.appendingPathComponent(fileName)
        
        guard audioURL != tempURL else {
            return audioURL!
        }
        
        if FileManager.default.fileExists(atPath: tempURL.path) {
            return tempURL
        }
        
        Task {
            await MainActor.run {
                try? data.write(to: tempURL)
            }
        }
        
        audioURL = tempURL
        
        return tempURL
    }
}
