//
//  TwibAudioManager.swift
//  Twib Music
//
//  Created by Lukas Cao on 8/27/24.
//

import Foundation
import MediaPlayer
import AVFoundation

var AudioManager = TwibAudioManager()

fileprivate let noSong = Song(name: "[Song Name]",
                              artists: [["name" : "[Artist Name]"]],
                              album: ["name": "",
                                      "images": [["url": "https://raw.githubusercontent.com/ohhh25/Twib-Music/main/Twib%20Music/Assets.xcassets/none.imageset/none.png"]]],
                              track_number: 0, duration: 0, sID: "", external_ids: [:], preview_url: "", explicit: -1, popularity: -1)

class TwibAudioManager: ObservableObject {
    private let audioSession = AVAudioSession.sharedInstance()
    private var player: AVPlayer?
    private var playerObserver: Any?
    @Published var isPlaying: Bool = false
    @Published var isSong: Bool = false
    @Published var elapsedTime: Double = 0
    @Published var progress: Float = 0
    @Published var currentSong: Song = noSong
    
    init() {
        do {
            try audioSession.setCategory(.playback, mode: .default)
        } catch {
            print("Failed to configure AVAudioSession: \(error.localizedDescription)")
        }
        setupRemoteTransportControls()
    }
    
    // MARK: BASIC FUNCTIONALITY
    func setCurrentSong(track: Song) {
        self.isSong = true
        self.currentSong = track
    }
    
    func playNew(track: Song, sameSong: Bool = false, previous: Bool = false) {
        DispatchQueue.main.async {
            if let observer = self.playerObserver {
                self.player?.removeTimeObserver(observer)
            }
            if self.isSong {
                if ((!sameSong) && (!previous)) {
                    QueueManager.addPreviousSong(self.currentSong)
                }
            }
            self.setCurrentSong(track: track)
            self.player = AVPlayer(url: self.currentSong.location)
            self.playerObserver = self.player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.1, preferredTimescale: 1000), queue: .main) { [weak self] time in
                guard let self = self else { return }
                self.elapsedTime = time.seconds
                let ms_duration = self.currentSong.duration
                self.progress = Float(time.seconds) / Float(ms_duration / 1000)
                if Int(time.seconds) >= (ms_duration / 1000) {
                    QueueManager.addPreviousSong(self.currentSong)
                    self.player?.pause()
                    self.isPlaying = false
                    self.currentSong = noSong
                    self.isSong = false
                    self.elapsedTime = 0
                    self.progress = 0
                    if QueueManager.repeatStatusIcon != "repeat.circle" {
                        QueueManager.updateQueue()
                    }
                    if !QueueManager.songQueue.isEmpty {
                        self.playNew(track: QueueManager.getNextSong())
                    }
                }
            }
            self.player?.play()
            self.isPlaying = true
            self.updateNowPlayingInfo()
        }
    }
    
    func togglePlayback() {
        DispatchQueue.main.async {
            self.isPlaying ? self.player?.pause() : self.player?.play()
            self.isPlaying.toggle()
            self.updateNowPlayingInfo()
        }
    }
    
    func skipToNextSong() {
        DispatchQueue.main.async {
            if QueueManager.repeatStatusIcon != "repeat.circle" {
                QueueManager.updateQueue()
            }
            if !QueueManager.songQueue.isEmpty {
                self.playNew(track: QueueManager.getNextSong())
            } else {
                QueueManager.addPreviousSong(self.currentSong)
                self.player?.pause()
                self.isPlaying = false
                self.currentSong = noSong
                self.isSong = false
                self.elapsedTime = 0
                self.progress = 0
            }
        }
    }
    
    func backToPreviousSong() {
        DispatchQueue.main.async {
            if self.elapsedTime > 2 {
                self.playNew(track: self.currentSong, sameSong: true)
            } else {
                if !QueueManager.previousSongs.isEmpty {
                    self.playNew(track: QueueManager.getPreviousSong(currentSong: self.currentSong), previous: true)
                }
            }
        }
    }
    
    // MARK: REMOTE CONTROLS
    func setupRemoteTransportControls() {
        let controlCenter = MPRemoteCommandCenter.shared()
        
        controlCenter.playCommand.addTarget { event in
            self.togglePlayback()
            return .success
        }
        
        controlCenter.pauseCommand.addTarget { event in
            self.togglePlayback()
            return .success
        }
        
        controlCenter.nextTrackCommand.addTarget { event in
            self.skipToNextSong()
            return .success
        }
        
        controlCenter.previousTrackCommand.addTarget { event in
            self.backToPreviousSong()
            return .success
        }
    }
    
    func updateNowPlayingInfo() {
        var nowPlayingInfo = getBasicInfo()

        guard let imageURL = URL(string: currentSong.image_url) else { return }
        fetchImage(imageURL) { image in
            if let image = image {
                let artwork = MPMediaItemArtwork(boundsSize: image.size) { size in
                    return image
                }
                nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
            }
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        }
    }
    
    // MARK: HELPER FUNCTIONS
    private func getBasicInfo() -> [String: Any] {
        var info: [String: Any] = [:]
        info[MPMediaItemPropertyTitle] = currentSong.name
        info[MPMediaItemPropertyArtist] = currentSong.artist
        info[MPMediaItemPropertyPlaybackDuration] = currentSong.duration / 1000
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player?.currentTime().seconds
        return info
    }
    
    private func fetchImage(_ url: URL, completion: @escaping (UIImage?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else {
                completion(nil)
                return
            }
            DispatchQueue.main.async {
                completion(image)
                return
            }
        }
        task.resume()
    }
    
    deinit {
        if let observer = playerObserver {
            player?.removeTimeObserver(observer)
        }
    }
}
