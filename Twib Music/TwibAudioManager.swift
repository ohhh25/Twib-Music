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
    private var player: AVPlayer?
    private let audioSession = AVAudioSession.sharedInstance()
    @Published var currentSong: Song = noSong
    @Published var playing: Bool = false
    @Published var isSong: Bool = false
    
    init() {
        do {
            try audioSession.setCategory(.playback, mode: .default)
        } catch {
            print("Failed to configure AVAudioSession: \(error.localizedDescription)")
        }
    }
    
    func setCurrentSong(track: Song) {
        self.currentSong = track
        self.isSong = true
    }
    
    func play(track: Song) {
        DispatchQueue.main.async {
            self.setCurrentSong(track: track)
            self.player = AVPlayer(url: self.currentSong.location)
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
