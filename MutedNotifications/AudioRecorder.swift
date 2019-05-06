//
//  ViewController.swift
//  MutedNotifications
//
//  Created by Ben Rudhart on 06.05.19.
//  Copyright © 2019 Ben Rudhart. All rights reserved.
//

import UIKit
import AVFoundation

final class AudioRecorder {
    private let session = AVAudioSession.sharedInstance()
    static let shared = AudioRecorder()

    var isRecording: Bool = false {
        didSet {
            try! session.setActive(isRecording, options: .notifyOthersOnDeactivation)
        }
    }

    private init() {
        requestPermission() {
            self.commonInit()
        }
    }

    private func requestPermission(completion: @escaping (() -> Void)) {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            assert(granted, "this example required mic permission")
            completion()
        }
    }

    func commonInit() {
//        setupNotifications()

        do {
            try session.setCategory(.playAndRecord,
                                    mode: .default,
                                    options: [.allowBluetooth, .duckOthers, .defaultToSpeaker])
            try session.setPreferredSampleRate(16000)
            try session.setPreferredIOBufferDuration(0.0058)
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    func setupNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(handleInterruption),
                                       name: AVAudioSession.interruptionNotification,
                                       object: session)
    }

    @objc private func handleInterruption(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let interruptionType = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                fatalError()
        }

        switch interruptionType {
        case .began:
            isRecording = false
        case .ended:
            if let interruptionValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let interruptionOptions = AVAudioSession.InterruptionOptions(rawValue: interruptionValue)
                let shouldResume = interruptionOptions.contains(.shouldResume)

                if shouldResume {
                    isRecording = true
                }
            }
        @unknown default:
            fatalError("unkown interruption type")
        }
    }
}
