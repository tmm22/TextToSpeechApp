import Foundation
import AVFoundation
import Combine

class AudioPlayer: NSObject, ObservableObject {
    @Published var isPlaying = false
    @Published var playbackProgress: Double = 0.0
    @Published var duration: Double = 0.0
    @Published var errorMessage: String?
    @Published var volume: Double = 1.0 {
        didSet {
            audioPlayer?.volume = Float(volume)
        }
    }
    @Published var playbackSpeed: Double = 1.0 {
        didSet {
            if let player = audioPlayer {
                player.rate = Float(playbackSpeed)
                if isPlaying && !player.isPlaying {
                    player.play()
                }
            }
        }
    }
    
    private var audioPlayer: AVAudioPlayer?
    private var progressTimer: Timer?
    
    override init() {
        super.init()
    }
    
    func playAudio(data: Data) {
        stop() // Stop any current playback
        
        do {
            audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            
            // Apply current settings
            audioPlayer?.volume = Float(volume)
            audioPlayer?.rate = Float(playbackSpeed)
            audioPlayer?.enableRate = true
            
            duration = audioPlayer?.duration ?? 0.0
            
            if audioPlayer?.play() == true {
                isPlaying = true
                startProgressTimer()
                errorMessage = nil
            } else {
                errorMessage = "Failed to start audio playback"
            }
        } catch {
            errorMessage = "Failed to create audio player: \(error.localizedDescription)"
        }
    }
    
    func pause() {
        audioPlayer?.pause()
        isPlaying = false
        stopProgressTimer()
    }
    
    func resume() {
        if audioPlayer?.play() == true {
            isPlaying = true
            startProgressTimer()
        }
    }
    
    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
        playbackProgress = 0.0
        duration = 0.0
        stopProgressTimer()
    }
    
    func seek(to time: Double) {
        guard let player = audioPlayer else { return }
        player.currentTime = time
        playbackProgress = time
    }
    
    private func startProgressTimer() {
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateProgress()
        }
    }
    
    private func stopProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
    }
    
    private func updateProgress() {
        guard let player = audioPlayer else { return }
        playbackProgress = player.currentTime
    }
}

extension AudioPlayer: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.isPlaying = false
            self.playbackProgress = 0.0
            self.stopProgressTimer()
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        DispatchQueue.main.async {
            self.errorMessage = "Audio decode error: \(error?.localizedDescription ?? "Unknown error")"
            self.stop()
        }
    }
}