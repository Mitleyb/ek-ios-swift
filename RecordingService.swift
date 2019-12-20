//
//  RecordingService.swift
//  Dating
//
//  Created by Eilon Krauthammer on 07/12/2019.
//  Copyright © 2019 Eilon Krauthammer. All rights reserved.
//

import Foundation
import AVFoundation

protocol RecordingServiceDelegate: AnyObject {
    func didFinishPlayingAudio()
}

class RecordingService: NSObject {
    
    // MARK: - Properties
    
    static var currentUserRecordURL: URL? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let url = paths[0].appendingPathComponent("recording.m4a")
        return FileManager.default.fileExists(atPath: url.path) ? url : nil
    }
        
    public private(set) var allowsRecording: Bool = false
    public private(set) var isPlaying: Bool = false {
        didSet {
            if isPlaying {
                audioPlayer.play()
            } else {
                audioPlayer.stop()
            }
        }
    }
    
    public var isValidURL: Bool {
        guard let url = playingFileURL else { return false }
        return FileManager.default.fileExists(atPath: url.path)
    }
    
    public var recordTime: TimeInterval {
        return audioPlayer.duration
    }
    
    public var currentTime: TimeInterval {
        return audioPlayer.currentTime
    }
    
    private weak var delegate: RecordingServiceDelegate?
    
    public private(set) var audioSession: AVAudioSession = AVAudioSession.sharedInstance()
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer!
    
    private var playingFileURL: URL?
    
    private let settings = [
        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
        AVSampleRateKey: 12000,
        AVNumberOfChannelsKey: 1,
        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
    ]

    // MARK: - Recording
    
    public init(delegate: RecordingServiceDelegate) throws {
        super.init()
        self.delegate = delegate        
        
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            self.requestRecordingPermission()
        } catch let err {
            throw err
        }
    }
    
    public func requestRecordingPermission() {
        audioSession.requestRecordPermission { [unowned self] allowed in
            self.allowsRecording = allowed
            if allowed {
                self.configureReocrder()
            }
        }
    }
    
    private func recordingFileURL() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("recording.m4a")
    }
    
    @discardableResult
    private func configureReocrder() -> Error? {
        do {
            let url = recordingFileURL()
            self.audioRecorder = try AVAudioRecorder(url: url, settings: self.settings)
            self.playingFileURL = url
            self.audioRecorder!.delegate = self
        } catch let err {
            return err
        }
        
        return nil
    }
    
    public func startRecording() throws {
        if let error = configureReocrder() { throw error }
        audioRecorder?.record()
    }
    
    public func finishRecording(success: Bool) {
        guard audioRecorder?.isRecording ?? false else { return }
        
        audioRecorder?.stop()
        audioRecorder = nil
    }

    // MARK: - Playing
    
    public init?(withFileURL url: URL?, delegate: RecordingServiceDelegate?) throws {
        super.init()
        self.playingFileURL = url
        self.delegate = delegate
        
        let (error, fileExists) = prepareToPlay()
        if !fileExists { return nil }
        if let err = error { throw err }
    }
    
    private func prepareToPlay(_ file: URL? = nil) -> (Error?, Bool) {
        guard let fileURL = file ?? playingFileURL else { return (nil, false) }
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try audioPlayer = AVAudioPlayer(contentsOf: fileURL)
                audioPlayer.delegate = self
                audioPlayer.prepareToPlay()
            } catch let err {
                return (err, false)
            }
        } else {
            print("File does not exist at the given path.")
            return (nil, false)
        }
        
        return (nil, true)
    }
    
    public func startPlaying(fileAtURL url: URL? = nil) throws {
        if let url = url {
            let (error, fileExists) = prepareToPlay(url)
            guard fileExists else { return }
            if let error = error { throw error }
        }
        
        self.isPlaying = true
    }
    
    public func pausePlaying() {
        guard isPlaying else { return }
        self.isPlaying = false
    }
    
    public func stopPlaying() {
        guard isPlaying else { return }
        self.isPlaying = false
        self.audioPlayer.currentTime = 0.0
    }
}

extension RecordingService : AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        delegate?.didFinishPlayingAudio()
    }
}

