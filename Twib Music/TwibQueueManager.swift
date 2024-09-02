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
    private var sID = ""
    
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
            self.shuffleMode = shuffle
            AudioManager.playNew(track: self.getNextSong())
        }
    }
    
    func getPlaylistUniqueID() -> String {
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
}
