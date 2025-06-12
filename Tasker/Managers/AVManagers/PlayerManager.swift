//
//  PlayerManager.swift
//  Tasker
//
//  Created by Rodion Akhmedov on 4/11/25.
//

import AVFoundation
import Foundation

@Observable
final class PlayerManager: PlayerManagerProtocol, Sendable {
    
    //MARK: Properties
    var isPlaying = false
    var task: TaskModel?
    
    
    //MARK: - Private properties
    private var player: AVAudioPlayer?
    private var currentTempURL: URL?
    private var playbackTimer: Timer?
    
    var currentTime: TimeInterval = 0.0
    var totalTime: TimeInterval = 0.0
    
    init() {
        print("init player manager")
    }
    func playAudioFromData(_ audio: Data, task: TaskModel) async {
        let audioSession = AVAudioSession.sharedInstance()
        self.task = task
        
        //        guard player != nil else {
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.allowAirPlay, .allowBluetooth, .allowBluetoothA2DP, .defaultToSpeaker, .duckOthers])
            try audioSession.overrideOutputAudioPort(.speaker)
            
            let audioURL = await createTempAudioFileAsync(from: audio)
            
            await MainActor.run {
                do {
                    player = try AVAudioPlayer(contentsOf: audioURL)
                    player?.prepareToPlay()
                    player?.play()
                    totalTime = player?.duration ?? 0.0
                    isPlaying = player?.isPlaying ?? false
                    startPlaybackTimer()
                } catch {
                    print("Couldn't create player: \(error)")
                }
            }
            
        } catch {
            print("Couldn't setup audio session: \(error)")
        }
        return
    }
    
    private func createTempAudioFileAsync(from data: Data) async -> URL {
        let tempDirectory = FileManager.default.temporaryDirectory
        var name: String
        
        if let task = task, let audio = task.audio {
            name = audio
        } else {
            name = UUID().uuidString
        }
        
        let fileName = "\(name).wav"
        let tempURL = tempDirectory.appendingPathComponent(fileName)
        
        if FileManager.default.fileExists(atPath: tempURL.path) {
            print("File already exists: \(tempURL.path)")
            return tempURL
        }
        
        await MainActor.run {
            do {
                try data.write(to: tempURL)
                print("Created temp file: \(tempURL.path)")
            } catch {
                print("Error creating temp file: \(error)")
            }
        }
        
        return tempURL
    }
    
    func stopToPlay() {
        player?.pause()
        isPlaying = false
        playbackTimer?.invalidate()
        playbackTimer = nil
    }
    
    private var isSeeking = false
    private var seekTimer: Timer?
    
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
}
