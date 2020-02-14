//
//  AudioPlaybackService.swift
//  Dating
//
//  Created by Eilon Krauthammer on 01/01/2020.
//  Copyright © 2020 Eilon Krauthammer. All rights reserved.
//

import Foundation
import AVFoundation

protocol PlaybackServiceDelegate: AnyObject {
    func didFinishPlayingAudio()
}

final class AudioPlaybackService: NSObject {
    enum AudioPlayerError: Error {
        case fileNotFound
        case invalidURL
    }
    
    private weak var delegate: PlaybackServiceDelegate?
    private var fileURL: URL!
        
    private var audioPlayer: AVAudioPlayer?

    public private(set) lazy var audioSession: AVAudioSession = AVAudioSession.sharedInstance()
    public private(set) var isPlaying: Bool = false {
        didSet {
            if isPlaying {
                audioPlayer?.play()
            } else {
                audioPlayer?.stop()
            }
        }
    }
    
    public init?(withFileURL url: URL?, delegate: PlaybackServiceDelegate?) throws {
        super.init()
        guard let url = url else { return nil }
        
        self.fileURL = url
        self.delegate = delegate
        
        try prepareToPlay()
    }
    
    private func prepareToPlay(_ file: URL? = nil) throws {
        guard let fileURL = fileURL else { throw AudioPlayerError.invalidURL }
        if FileManager.default.fileExists(atPath: fileURL.path) {
            let player = try AVAudioPlayer(contentsOf: fileURL)
            player.delegate = self
            self.audioPlayer = player
            try? audioSession.overrideOutputAudioPort(.speaker)
            DispatchQueue.main.async {
                player.prepareToPlay()
            }
        } else {
            print("File does not exist at the given path.")
            throw AudioPlayerError.fileNotFound
        }
    }
    
    public func startPlaying(fileAtURL url: URL? = nil) throws {
        if let url = url {
            try prepareToPlay(url)
        }
        
        self.isPlaying = true
    }
    
    public func pausePlaying() {
        self.isPlaying = false
    }
    
    public func stopPlaying() {
        guard isPlaying else { return }
        self.isPlaying = false
        self.audioPlayer?.currentTime = 0.0
    }
    
}

// MARK: - Public helpers

extension AudioPlaybackService {
    public var isValidURL: Bool {
        guard let url = self.fileURL else { return false }
        return FileManager.default.fileExists(atPath: url.path)
    }
    
    public var recordTime: TimeInterval? {
        return audioPlayer?.duration
    }
    
    public var currentTime: TimeInterval? {
        get {
            return audioPlayer?.currentTime
        } set {
            if let newTime = newValue {
                audioPlayer?.currentTime = newTime
            }
        }
    }
    
    static func downloadWebURL(_ url: URL, completion: @escaping (URL?) -> Void) {
        URLSession.shared.downloadTask(with: url) { (url, _, _) in
            completion(url)
        }.resume()
    }
}

// MARK: - Delegate

extension AudioPlaybackService: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        delegate?.didFinishPlayingAudio()
    }
}


