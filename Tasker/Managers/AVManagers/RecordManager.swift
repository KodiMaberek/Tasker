//
//  RecordManager.swift
//  Tasker
//
//  Created by Rodion Akhmedov on 4/10/25.
//

import AVFoundation
import Foundation

@Observable
final class RecordManager: RecordingProtocol, @unchecked Sendable {
    private var avAudioRecorder: AVAudioRecorder?
    
    var timer: Timer?
    var currentlyTime = 0.0
    var progress = 0.00
    var maxDuration = 15.00
    var decibelLevel: Float = 0.0
    
    private var previousDecibelLevel: Float = 0.0
    
    private var tempFileURL: URL {
        let libraryDirrectory = FileManager.default.urls(for: .libraryDirectory, in: .allDomainsMask).first!
        return libraryDirrectory.appending(path: "Sounds")
    }
    
    //MARK: Start recording
    var relativePath = ""
    var uniqId: String = ""
    
    var baseDirectoryURL: URL {
        let libraryDirrectory = FileManager.default.urls(for: .libraryDirectory, in: .allDomainsMask).first!
        return libraryDirrectory.appending(path: "Sounds")
    }
    
    //MARK: Fix trouble with leaks
    func startRecording() async {
        guard let dirrectoryURL = createDirectory() else {
            print("Invalide path to dirrectory")
            return
        }
        
        uniqId = UUID().uuidString
        relativePath = "New_recorder_\(uniqId).wav"
        
        let fileName = dirrectoryURL.appending(path: relativePath)
        
        let setting: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsBigEndianKey: false,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
        ]
        do {
            avAudioRecorder = try AVAudioRecorder(url: fileName, settings: setting)
            avAudioRecorder?.prepareToRecord()
            avAudioRecorder?.isMeteringEnabled = true
            avAudioRecorder?.record()
            
            await updateTime()
        } catch {
            fatalError()
        }
    }
    
    func createDirectory() -> URL? {
        let soundDirectory = baseDirectoryURL
        
        do {
            try FileManager.default.createDirectory(at: soundDirectory, withIntermediateDirectories: true, attributes: nil)
            
        } catch let error as NSError {
            print("Can't create a directory, \(error)")
            return nil
        }
        return soundDirectory
    }
    
    //MARK: Stop recording
    func stopRecording() async  {
        timer?.invalidate()
        timer = nil
        avAudioRecorder?.stop()
        avAudioRecorder?.isMeteringEnabled = false
        progress = 0.0
        currentlyTime = 0.0
    }
    
    //MARK: Check and update recording time
    private func updateTime() async {
        Task { @MainActor in
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                self.currentlyTime = self.avAudioRecorder!.currentTime
                self.progress = (self.currentlyTime / self.maxDuration)
                self.updateDecibelLvl()
            }
        }
    }
    
    
    //MARK: Functions for get and showing decibel LVL
    private func updateDecibelLvl() {
        guard let recorder = avAudioRecorder else {
            return
        }
        
        recorder.updateMeters()
        let decibelLevel = recorder.averagePower(forChannel: 0)
        
        let mappedValue = mapDecibelLessNoiseSensitive(dB: decibelLevel)
        
        let inertiaFactor: Float = 0.5
        let smoothedValue = previousDecibelLevel * inertiaFactor + mappedValue * (1 - inertiaFactor)
        
        self.decibelLevel = smoothedValue
        self.previousDecibelLevel = smoothedValue
    }
    
    private func mapDecibelLessNoiseSensitive(dB: Float, minDcb: Float = -80, maxDcb: Float = 0, minRange: Float = 0.0, maxRange: Float = 1.5) -> Float {
        let clampedDB = max(min(dB, maxDcb), minDcb)
        
        let normalizedDB = (clampedDB - minDcb) / (maxDcb - minDcb)
        
        let power: Float = 1.5
        let correctedValue = pow(normalizedDB, power)
        
        let noiseThreshold: Float = 0.1
        let noiseSuppressedValue = correctedValue < noiseThreshold ? 0 : correctedValue
        
        let result = minRange + noiseSuppressedValue * (maxRange - minRange)
        return result
    }
}
