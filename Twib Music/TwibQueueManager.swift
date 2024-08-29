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
    private var sID = ""
    
    func addToQueue(_ song: Song) {
        DispatchQueue.main.async {
            if !AudioManager.isSong {
                AudioManager.playNew(track: song)
            } else {
                self.songQueue.append(song)
            }
        }
    }
    
    func addPlaylistToQueue(_ playlist: [Song], sID: String) {
        DispatchQueue.main.async {
            self.sID = sID
            self.songQueue.removeAll()
            self.songQueue.append(contentsOf: playlist)
            AudioManager.playNew(track: self.getNextSong())
        }
    }
    
    func getPlaylistUniqueID() -> String {
        return self.sID
    }
    
    func getNextSong() -> Song {
        return self.songQueue.removeFirst()
    }
    
    func removeFromQueue(_ location: Int) {
        DispatchQueue.main.async {
            self.songQueue.remove(at: location)
        }
    }
}
