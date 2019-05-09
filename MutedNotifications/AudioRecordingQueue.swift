//
//  AudioRecordingQueue.swift
//  MutedNotifications
//
//  Created by Ben Rudhart on 06.05.19.
//  Copyright © 2019 Ben Rudhart. All rights reserved.
//

import Foundation
import AVFoundation

final class AudioRecordingQueue {
    private var queue: AudioQueueRef?
    private var input: ((UnsafePointer<Int16>) -> Void)?
    
    func setRecording(_ isRecording: Bool) {
        if isRecording {
            start()
        } else {
            queue.map { stop(queue: $0) }
        }
    }
    
    private func start() {
        guard let audioQueue = setupAudioQueue() else { return }
        AudioQueueStart(audioQueue, nil)
    }
    
    private func stop(queue: AudioQueueRef) {
        AudioQueueStop(queue, true)
        AudioQueueDispose(queue, false)
    }
    
    private func setupAudioQueue() -> AudioQueueRef? {
        guard let audioQueue = setupAudioInput() else { return nil}
        setupBuffers(count: 3, audioQueue: audioQueue)
        return audioQueue
    }
    
    private func setupAudioInput() -> AudioQueueRef? {
        var format = audioStreamDescription
        let callback = audioQueueCallback()
        let userData = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        AudioQueueNewInput(&format, callback, userData, nil, nil, 0, &queue)
        return queue
    }
    
    private func setupBuffers(count: Int, audioQueue: AudioQueueRef) {
        for _ in 0..<count {
            setupBuffer(audioQueue: audioQueue)
        }
    }
    
    private func setupBuffer(audioQueue: AudioQueueRef) {
        var bufferRef: AudioQueueBufferRef?
        AudioQueueAllocateBuffer(audioQueue, 1024, &bufferRef)
        bufferRef.map { _ = AudioQueueEnqueueBuffer(audioQueue, $0, 0, nil) }
    }
    
    private var audioStreamDescription: AudioStreamBasicDescription {
        return AudioStreamBasicDescription(mSampleRate: 16000,
                                           mFormatID: kAudioFormatLinearPCM,
                                           mFormatFlags: kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked,
                                           mBytesPerPacket: 2,
                                           mFramesPerPacket: 1,
                                           mBytesPerFrame: 2,
                                           mChannelsPerFrame: 1,
                                           mBitsPerChannel: 16,
                                           mReserved: 0)
    }
    
    private func audioQueueCallback() -> AudioQueueInputCallback {
        return { userData, queue, bufferRef, _, _, _ in
            guard let userData = userData else { return }
            let recordingQueue = Unmanaged<AudioRecordingQueue>.fromOpaque(userData).takeUnretainedValue()
            recordingQueue.handle(queue: queue, bufferRef: bufferRef)
        }
    }
    
    private func handle(queue: AudioQueueRef, bufferRef: AudioQueueBufferRef) {
        if let input = input {
            let pcm = bufferRef.pointee.mAudioData.assumingMemoryBound(to: Int16.self)
            input(pcm)
        }
        
        AudioQueueEnqueueBuffer(queue, bufferRef, 0, nil)
    }
}
