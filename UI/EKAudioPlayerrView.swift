//
//  RecordPlayView.swift
//  Dating
//
//  Created by Eilon Krauthammer on 08/12/2019.
//  Copyright © 2019 Eilon Krauthammer. All rights reserved.
//

import UIKit
import AVFoundation

final class AudioPlayerView: UIView {

    // MARK: - Properties
    
    public var url: URL? {
        didSet {
            commonSetup()
        }
    }
    
    public var isValidURL: Bool {
        guard let service = playbackService else { return false }
        return service.isValidURL
    }
    
    public var speakerOutput: AVAudioSession.PortOverride = .none {
        didSet {
            try? playbackService?.audioSession.overrideOutputAudioPort(speakerOutput)
        }
    }
    
    public var accentColor: UIColor = Colors.red {
        willSet {
            knob.backgroundColor = newValue
            controlButton.tintColor = newValue
        }
    }
    
    @IBInspectable public var draggingAllowed: Bool = true
    @IBInspectable public var constraintHeight: Bool = false
    
    private var padding: CGFloat = 0.0
    
    private var playbackService: AudioPlaybackService!
    
    private var storyboardInit = false
    
    private var timer: Timer!
    
    public var isPlaying: Bool = false {
        didSet {
            if isPlaying {
                try? playbackService?.startPlaying()
                setPlayTimer()
            } else {
                if playbackService?.isPlaying ?? false {
                    playbackService.pausePlaying()
                    timer.invalidate()
                }
            }
            controlButton.setImage(isPlaying ? Images.stop : Images.play, for: .normal)
        }
    }
    
    private var isDragging: Bool = false
    
    // MARK: - UI Elements
    
    private var hStack: UIStackView!
    
    private lazy var knob: UIView = {
        let knob = UIView()
        let knobDimension: CGFloat = 14.0
        knob.frame.size = .square(knobDimension)
        knob.backgroundColor = accentColor
        knob.layer.roundCorners(of: .custom(knobDimension / 2))
        knob.isUserInteractionEnabled = true
        return knob
    }()
    
    private let bar: UIView = {
        let barHeight: CGFloat = 4.0
        let bar = UIView()
        bar.backgroundColor = Colors.component
        bar.heightAnchor.constraint(equalToConstant: barHeight).isActive = true
        bar.layer.roundCorners(of: .custom(barHeight / 2))
        return bar
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel.defaultLabel(text: "", size: UIFont.systemFontSize, color: Colors.secondaryLabel, maxLines: 1)
        label.textAlignment = .center
        return label
    }()

    private lazy var controlButton: UIButton = {
        let buttonDimension: CGFloat = 36.0
        let button = UIButton()
        button.setImage(Images.play, for: .normal)
        button.tintColor = accentColor //UIColor.white.withAlphaComponent(0.8)
        button.imageView?.contentMode = .scaleAspectFit
        button.contentEdgeInsets = .even(6.0)
        button.constraintAspectRatio(1.0, width: buttonDimension)
        button.addTarget(self, action: #selector(playPause), for: .touchUpInside)
        return button
    }()
    
    override var intrinsicContentSize: CGSize {
        return CGSize(
            width: UIScreen.main.bounds.width * 0.65,
            height: 0.0
        )
    }
    
    // MARK: - Life Cycle
    
    public init(url: URL? = nil, padding: CGFloat = 0, constraintHeight: Bool = false) {
        super.init(frame: .zero)
        backgroundColor = nil
        self.url = url
        self.padding = padding
        self.constraintHeight = constraintHeight
        commonSetup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        storyboardInit = true
    }

    
    private var didLayout = false
    private var shouldApplyBackground = false
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if shouldApplyBackground {
            layer.roundCorners(of: .regular)
        }
        
        if !didLayout {
            didLayout = true
            if storyboardInit {
                commonSetup()
            }
            
            knob.frame.origin.x = bar.bounds.minX
            knob.center.y = bar.relativeCenter.y + 2
        }
    }
    
    // MARK: - Setup
    
    private func commonSetup() {
        if constraintHeight {
            self.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
        }
        
        guard let url = self.url else {
            return
        }
        
        guard let service = try? AudioPlaybackService(withFileURL: url, delegate: self) else { return }
        self.playbackService = service
        
        self.timeLabel.text = self.playbackService.recordTime!.timeString
        self.knob.frame.origin.x = 0.0
        
        self.hStack = UIStackView(arrangedSubviews: [controlButton, bar, timeLabel])
        self.hStack.axis = .horizontal
        self.hStack.spacing = 16.0
        self.hStack.alignment = .center
        self.hStack.semanticContentAttribute = .forceLeftToRight
        
//        if hStack.isDescendant(of: self) {
//            hStack.removeFromSuperview()
//        }
        
        self.addSubview(self.hStack)
        self.hStack.vfix(in: self)
        self.hStack.hfix(in: self, padding: self.padding)
        
        self.bar.addSubview(self.knob)
    }
    
    private func setPlayTimer() {
        timer?.invalidate()
        
        let duration = floor(playbackService.recordTime ?? 0)
        var currentTime = ceil(playbackService.currentTime ?? 0) {
            didSet {
                timeLabel.text = currentTime.timeString
            }
        }
        
        timeLabel.text = currentTime.timeString
        
        let knobFraction = (bar.frame.width / CGFloat(duration)) - (knob.frame.width / CGFloat(duration))
        self.knob.frame.origin.x = knobFraction * CGFloat(ceil(currentTime))
        
        timer = .scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            currentTime += 1
            animated { self.knob.frame.origin.x += knobFraction }
            print(currentTime, duration)
            if currentTime == duration {
                timer.invalidate()
            }
        }
    }
    
    // MARK: - Actions

    public func applyBackground() {
        shouldApplyBackground = true
        clipsToBounds = true
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        insertSubview(blurView, at: 0)
        blurView.hfix(in: self)
        blurView.vfix(in: self)
        
        self.controlButton.tintColor = UIColor.white.withAlphaComponent(0.8)

    }
    
    private func setTime(_ fraction: Double) {
        guard let recTime = playbackService.recordTime else { return }
        playbackService.currentTime = recTime * fraction
        isPlaying = false
    }
    
    @objc private func playPause() {
        self.isPlaying.toggle()
    }
    
}

extension AudioPlayerView : PlaybackServiceDelegate {
    func didFinishPlayingAudio() {
        self.playbackService.stopPlaying()
        self.isPlaying = false
    }
}

// MARK: - Dragging
extension AudioPlayerView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard draggingAllowed else { return }
        
        if let touchPoint = touches.first?.location(in: self) {
            if touchPoint.x >= bar.frame.minX {
                isDragging = true
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isDragging else { return }
        if let touchPoint = touches.first?.location(in: self) {
            let nextX = touchPoint.x
            guard nextX <= bar.frame.maxX && nextX >= bar.frame.minX else {
                isDragging = false
                return
            }

            // Did drag
            knob.center.x = nextX - bar.frame.minX
            let fraction = (knob.frame.minX + knob.frame.width) / bar.frame.width
            self.setTime(Double(fraction))
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isDragging = false
    }
}
