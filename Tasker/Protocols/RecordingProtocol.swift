//
//  RecordingProtocol.swift
//  Tasker
//
//  Created by Rodion Akhmedov on 4/11/25.
//

import Foundation

protocol RecordingProtocol {
    var timer: Timer? { get set }
    var currentlyTime: Double { get set }
    var progress: Double { get set }
    var maxDuration: Double { get set }
    var decibelLevel: Float { get set }
    var relativePath: String { get set }
    var uniqId: String { get set }
    
    func startRecording() async
    func stopRecording() async
    func createDirectory() -> URL?
}
