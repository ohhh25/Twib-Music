//
//  TwibQueueManager.swift
//  Twib Music
//
//  Created by Lukas Cao on 8/29/24.
//

import Foundation

var QueueManager = TwibQueueManager()

class TwibQueueManager: ObservableObject {
    @Published var songQueue: [Song] = []
    @Published var previousSongs: [Song] = []
    @Published var shuffleMode = false
    @Published var repeatStatusIcon = "repeat.circle"
    private var sID = ""
    private var sIDs: [String: [Song]] = [:]
    private var repeatStatus = ""
    private var repeatQueue: [Song] = []
    
    func updateQueue(_ shuffle: Bool) {
        DispatchQueue.main.async {
            guard let array = self.sIDs[self.sID] else { return }
            self.shuffleMode = shuffle
            if self.shuffleMode {
                self.songQueue.shuffle()
            } else {
                let i = AudioManager.currentSong.twibIdx + 1
                self.songQueue.removeAll()
                self.songQueue.append(contentsOf: array[i..<array.endIndex])
            }
            if self.repeatStatus.count > 0 {
                self.repeatQueue.removeAll()
                self.repeatQueue.append(contentsOf: shuffle ? array.shuffled() : array)
            }
        }
    }
    
    func updateQueue(repeat: Bool = true) {
        DispatchQueue.main.async {
            if (!self.repeatQueue.isEmpty && self.songQueue.isEmpty) {
                self.songQueue.append(contentsOf: self.repeatQueue)
                if self.repeatStatus == "once" {
                    self.repeatQueue.removeAll()
                }
            }
        }
    }
    
    func addToQueue(_ song: Song) {
        if song.image_url == "https://raw.githubusercontent.com/ohhh25/Twib-Music/main/Twib%20Music/Assets.xcassets/none.imageset/none.png" {
            return
        }
        DispatchQueue.main.async {
            if !AudioManager.isSong {
                AudioManager.playNew(track: song)
            } else {
                self.songQueue.append(song)
            }
        }
    }
    
    func addPlaylistToQueue(_ playlist: [Song], sID: String, shuffle: Bool) {
        DispatchQueue.main.async {
            self.songQueue.removeAll()
            self.songQueue.append(contentsOf: shuffle ? playlist.shuffled() : playlist)
            self.sID = sID
            self.sIDs[sID] = playlist
            self.shuffleMode = shuffle
            AudioManager.playNew(track: self.getNextSong())
            if self.repeatStatus.count > 0 {
                self.repeatQueue.removeAll()
                self.repeatQueue.append(contentsOf: shuffle ? playlist.shuffled() : playlist)
            }
        }
    }
    
    func getPlaylistUniqueID(remove: Bool = false) -> String {
        if remove {
            self.sID = ""
        }
        return self.sID
    }
    
    private func maintainPreviousSongs() {
        DispatchQueue.main.async {
            while self.previousSongs.count >= 20 {
                self.previousSongs.removeFirst()
            }
        }
    }
    
    func addPreviousSong(_ song: Song) {
        if song.image_url == "https://raw.githubusercontent.com/ohhh25/Twib-Music/main/Twib%20Music/Assets.xcassets/none.imageset/none.png" {
            return
        }
        DispatchQueue.main.async {
            self.maintainPreviousSongs()
            self.previousSongs.append(song)
        }
    }
    
    func getNextSong() -> Song {
        return self.songQueue.removeFirst()
    }
    
    func getPreviousSong(currentSong: Song?) -> Song {
        DispatchQueue.main.async {
            if let currentSong = currentSong {
                if currentSong.image_url == "https://raw.githubusercontent.com/ohhh25/Twib-Music/main/Twib%20Music/Assets.xcassets/none.imageset/none.png" {
                    return
                }
                self.songQueue.insert(currentSong, at: 0)
            }
        }
        return self.previousSongs.removeLast()
    }
    
    func removeFromQueue(_ location: Int) {
        DispatchQueue.main.async {
            self.songQueue.remove(at: location)
        }
    }
    
    func handleRepeatStatus() {
        DispatchQueue.main.async {
            self.repeatQueue.removeAll()
            switch self.repeatStatus {
            case "continuous":
                self.repeatStatus = "once"
                if let songs = self.sIDs[self.sID] {
                    self.repeatQueue.append(contentsOf: self.shuffleMode ? songs.shuffled() : songs)
                } else if AudioManager.isPlaying {
                    self.repeatQueue.append(AudioManager.currentSong)
                }
            case "once":
                self.repeatStatus = ""
            default:
                self.repeatStatus = "continuous"
                if let songs = self.sIDs[self.sID] {
                    self.repeatQueue.append(contentsOf: self.shuffleMode ? songs.shuffled() : songs)
                } else if AudioManager.isPlaying {
                    self.repeatQueue.append(AudioManager.currentSong)
                }
            }
            self.syncRepeatIcon()
        }
    }
    
    private func syncRepeatIcon() {
        switch self.repeatStatus {
        case "continuous":
            self.repeatStatusIcon = "repeat.circle.fill"
        case "once":
            self.repeatStatusIcon = "repeat.1.circle.fill"
        default:
            self.repeatStatusIcon = "repeat.circle"
        }
    }
}
