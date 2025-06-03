//
//  RecordingProtocol.swift
//  Tasker
//
//  Created by Rodion Akhmedov on 4/11/25.
//

import Foundation

protocol RecordingProtocol {
    var timer: Timer? { get }
    var currentlyTime: Double { get }
    var progress: Double { get }
    var maxDuration: Double { get }
    var decibelLevel: Float { get }
    var fileName: URL? { get }
    var isRecording: Bool { get set }
    
    func startRecording() async
    func stopRecording() -> URL?
    func clearFileFromDirectory()
}
