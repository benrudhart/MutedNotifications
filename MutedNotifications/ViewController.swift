//
//  ViewController.swift
//  MutedNotifications
//
//  Created by Ben Rudhart on 06.05.19.
//  Copyright © 2019 Ben Rudhart. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet private var secondsLabel: UILabel!
    @IBOutlet private var recordingLabel: UILabel!
    @IBOutlet private var notificationsLabel: UILabel!
    @IBOutlet private var slider: UISlider!
    @IBOutlet private var recordingSwitch: UISwitch!

    private var seconds: Int = 0 {
        didSet { secondsLabel.text = "\(seconds)" }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        changeSeconds(slider)
        toggleAudioRecording(recordingSwitch)
    }

    // MARK: - Actions
    @IBAction func changeSeconds(_ sender: UISlider) {
        seconds = Int(slider.value.rounded())
    }

    @IBAction func toggleAudioRecording(_ sender: UISwitch) {
        let isRecording = sender.isOn

        AudioRecorder.shared.isRecording = isRecording
        
        recordingLabel.text = isRecording
            ? "Audio recording enabled"
            : "Audio recording disabled"
        
        notificationsLabel.text = isRecording
            ? "Notifications are muted"
            : "Notifications are not muted"
    }

    @IBAction func scheduleNotification(_ sender: Any) {
        Notifications.shared.scheduleNotification(in: seconds)
    }
}

