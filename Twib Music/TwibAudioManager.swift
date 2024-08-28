//
//  TwibAudioManager.swift
//  Twib Music
//
//  Created by Lukas Cao on 8/27/24.
//

import Foundation
import AVFoundation

var AudioManager = TwibAudioManager()

fileprivate let noSong = Song(name: "[Song Name]",
                              artists: [["name" : "[Artist Name]"]],
                              album: ["name": "",
                                      "images": [["url": "https://raw.githubusercontent.com/ohhh25/Twib-Music/main/Twib%20Music/Assets.xcassets/none.imageset/none.png"]]],
                              track_number: 0, duration: 0, sID: "", external_ids: [:], preview_url: "", explicit: -1, popularity: -1)

class TwibAudioManager: ObservableObject {
    private let audioSession = AVAudioSession.sharedInstance()
    @Published var playing: Bool = false
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
    }
    
    // MARK: BASIC FUNCTIONALITY
    func setCurrentSong(track: Song) {
        self.isSong = true
        self.currentSong = track
    }
    
    func play(track: Song) {
        DispatchQueue.main.async {
            if let observer = self.playerObserver {
                self.player?.removeTimeObserver(observer)
            }
            self.setCurrentSong(track: track)
            self.player = AVPlayer(url: self.currentSong.location)
            self.playerObserver = self.player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.1, preferredTimescale: 1000), queue: .main) { [weak self] time in
                self?.elapsedTime = time.seconds
                if let ms_duration = self?.currentSong.duration {
                    self?.progress = Float(time.seconds) / Float(ms_duration / 1000)
                    if Int(time.seconds) >= (ms_duration / 1000) {
                        self?.player?.pause()
                        self?.isPlaying = false
                        self?.currentSong = noSong
                        self?.isSong = false
                        self?.elapsedTime = 0
                        self?.progress = 0
                    }
                }
            }
            self.player?.play()
            self.playing = true
        }
    }
    
    func togglePlayback() {
        DispatchQueue.main.async {
            if self.playing {
                self.player?.pause()
                self.playing = false
            } else {
                self.player?.play()
                self.playing = true
            }
        }
    }
}
