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
    
    func addToQueue(_ song: Song) {
        DispatchQueue.main.async {
            if !AudioManager.isSong {
                AudioManager.playNew(track: song)
            } else {
                self.songQueue.append(song)
            }
        }
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
