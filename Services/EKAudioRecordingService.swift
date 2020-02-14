//
//  RecordingService.swift
//  Dating
//
//  Created by Eilon Krauthammer on 07/12/2019.
//  Copyright © 2019 Eilon Krauthammer. All rights reserved.
//

import Foundation
import AVFoundation

final class AudioRecordingService: NSObject {
    enum RecordPath: String {
        case `default`, temp
        fileprivate var pathId: String {
            return rawValue + "-recording.m4a"
        }
        
        public var url: URL? {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let url = paths[0].appendingPathComponent(pathId)
            return FileManager.default.fileExists(atPath: url.path) ? url : nil
        }
    }
    
    // MARK: - Properties
    
    public var currentUserRecordURL: URL? {
        recordPath.url
    }
        
    public private(set) var allowsRecording: Bool = false
    
    public var isRecording: Bool { audioRecorder?.isRecording ?? false }
    
    private weak var delegate: PlaybackServiceDelegate?
    
    public private(set) var audioSession: AVAudioSession = AVAudioSession.sharedInstance()
    private var audioRecorder: AVAudioRecorder?
        
    private let settings = [
        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
        AVSampleRateKey: 12000,
        AVNumberOfChannelsKey: 1,
        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
    ]

    public var exportOutputURL: URL? {
        let pathURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return pathURL?.appendingPathComponent(recordPath.pathId)
    }
    
    private var recordPath: RecordPath!
    
    // MARK: - Recording
    
    public init(delegate: PlaybackServiceDelegate? = nil, path: RecordPath) throws {
        super.init()
        self.delegate = delegate
        self.recordPath = path
        
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
                try? self.configureReocrder()
            }
        }
    }
    
    public func recordingFileURL() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent(recordPath.pathId)
    }
    
    private func configureReocrder() throws {
        do {
            let url = recordingFileURL()
            self.audioRecorder = try AVAudioRecorder(url: url, settings: self.settings)
            self.audioRecorder!.delegate = self
        } catch let err {
            throw err
        }
    }
    
    public func startRecording() throws {
        do {
            try configureReocrder()
        } catch let error { throw error }
        audioRecorder?.record()
    }
    
    public func finishRecording(success: Bool) {
        guard audioRecorder?.isRecording ?? false else { return }
        audioRecorder?.stop()
        audioRecorder = nil
    }
    
    public func export(fileType: AVFileType = .m4a, completion: @escaping (() -> Void)) {
        let asset = AVAsset(url: recordingFileURL())
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else { return }
        exportSession.outputFileType = fileType
        exportSession.metadata = asset.metadata
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.outputURL = exportOutputURL
        exportSession.exportAsynchronously {
            print("Export finished.")
            completion()
        }
    }
}

extension AudioRecordingService : AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
}

