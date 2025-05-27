//
//  PlayerManager.swift
//  Tasker
//
//  Created by Rodion Akhmedov on 4/11/25.
//

import AVFoundation
import Foundation

@Observable
final class PlayerManager: PlayerProtocol, Sendable {
    
    //MARK: Properties
    var isPlaying = false
    var task: TaskModel?
    
    
    //MARK: - Private properties
    private var player: AVAudioPlayer?
    private var currentTempURL: URL?
    private var playbackTimer: Timer?
    
    func playAudioFromData(_ audio: Data, task: TaskModel) async {
        let audioSession = AVAudioSession.sharedInstance()
        self.task = task
        
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.allowAirPlay, .allowBluetooth, .allowBluetoothA2DP, .defaultToSpeaker, .duckOthers])
            try audioSession.overrideOutputAudioPort(.speaker)
            
            let audioURL = await createTempAudioFileAsync(from: audio)
            
            await MainActor.run {
                do {
                    player = try AVAudioPlayer(contentsOf: audioURL)
                    player?.prepareToPlay()
                    player?.play()
                    isPlaying = player?.isPlaying ?? false
                    checkIsPlaying()
                } catch {
                    print("Couldn't create player: \(error)")
                }
            }
            
        } catch {
            print("Couldn't setup audio session: \(error)")
        }
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
    
    func checkIsPlaying() {
        playbackTimer?.invalidate()
        
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            Task { @MainActor in
                if self.player?.isPlaying == false {
                    self.isPlaying = false
                    self.playbackTimer?.invalidate()
                    self.playbackTimer = nil
                }
            }
        }
    }
    
    func stopToPlay() {
        player?.stop()
        player = nil
        isPlaying = false
        playbackTimer?.invalidate()
        playbackTimer = nil
    }
}
