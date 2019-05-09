//
//  AudioRecorder.swift
//  MutedNotifications
//
//  Created by Ben Rudhart on 06.05.19.
//  Copyright © 2019 Ben Rudhart. All rights reserved.
//

import UIKit
import AVFoundation

final class AudioRecorder {
    static let shared = AudioRecorder()
    private let session = AVAudioSession.sharedInstance()
    private let recordingQueue = AudioRecordingQueue()

    var isRecording: Bool = false {
        didSet { recordingQueue.setRecording(isRecording) }
    }

    private init() {
        registerNotifications()
        
        requestPermission() {
            self.setupSession()
            self.recordingQueue.setRecording(self.isRecording)
        }
    }

    private func requestPermission(completion: @escaping (() -> Void)) {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            assert(granted, "this example requires mic permission")
            completion()
        }
    }

    func setupSession() {
        do {
            try session.setCategory(.playAndRecord, mode: .default, options: [.allowBluetooth, .duckOthers, .defaultToSpeaker])
            try session.setPreferredSampleRate(16000)
            try session.setPreferredIOBufferDuration(0.0058)
            try session.setActive(true, options: .notifyOthersOnDeactivation)
            try session.setPreferredInputNumberOfChannels(1)
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption), name: AVAudioSession.interruptionNotification, object: session)
    }

    @objc private func handleInterruption(_ notification: Notification) {
        guard let interruptionType = notification.audioInterruptionType else { fatalError() }

        switch interruptionType {
        case .began:
            isRecording = false
        case .ended:
            if notification.shouldResumeRecording {
                isRecording = true
            }
        @unknown default:
            fatalError("unkown interruption type")
        }
    }
}

private extension Notification {
    var audioInterruptionType: AVAudioSession.InterruptionType? {
        let interruptionValue = userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt
        return interruptionValue.flatMap { AVAudioSession.InterruptionType(rawValue: $0) }
    }
    
    private var audioInterruptionOptions: AVAudioSession.InterruptionOptions? {
        let optionValue = userInfo?[AVAudioSessionInterruptionOptionKey] as? UInt
        return optionValue.map { AVAudioSession.InterruptionOptions(rawValue: $0) }
    }
    
    var shouldResumeRecording: Bool {
        return audioInterruptionOptions ~= .shouldResume
    }
}
