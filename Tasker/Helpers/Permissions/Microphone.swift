//
//  Microphone.swift
//  Tasker
//
//  Created by Rodion Akhmedov on 4/11/25.
//

import SwiftUI
import Foundation

enum MicrophonePermission: Error {
    case silentError
    case microphoneIsNotAvalible
    
    
    func showingAlert() -> Alert {
        switch self {
        case .microphoneIsNotAvalible:
            Alert(title: Text("Microphone access denied"), message: Text("To record audio, please enable Microphone access in Settings."), primaryButton: .default(Text("Settings"), action: openSetting), secondaryButton: .cancel())
        case .silentError: fatalError()
        }
    }
    
    private func openSetting() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}
