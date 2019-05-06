//
//  ViewController.swift
//  MutedNotifications
//
//  Created by Ben Rudhart on 06.05.19.
//  Copyright © 2019 Ben Rudhart. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var secondsLabel: UILabel!
    @IBOutlet var recordingLabel: UILabel!
    @IBOutlet var slider: UISlider!
    @IBOutlet var recordingSwitch: UISwitch!

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
        recordingLabel.text = sender.isOn
            ? "Audio recording enabled"
            : "Audio recording disabled"
    }

    @IBAction func scheduleNotification(_ sender: Any) {
    }
}

