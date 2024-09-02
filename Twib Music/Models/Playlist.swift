//
//  Playlist.swift
//  Twib Music
//
//  Created by Lukas Cao on 8/5/24.
//

import Foundation

class Playlist: Identifiable, ObservableObject {
    let name: String
    let description: String
    let tracks_url: String
    let image_url: String
    let visible: Int
    let sID: String
    @Published var tracks: [Song] = []

    var requestBody: [String: Any] = [:]
    var downloadStatus = "Not Downloaded"
    @Published var downloadStatusIcon = "exclamationmark.arrow.trianglehead.2.clockwise.rotate.90"
    @Published var downloadProgress: Double = 0
    private var expectedDownloadSize: Int64?
    
    // MARK: BASIC INIT
    init(name: String, description: String, tracks_url: String, image_url: String, visible: Int, sID: String) {
        self.name = name
        self.description = description
        self.tracks_url = tracks_url
        self.image_url = image_url
        self.visible = visible
        self.sID = sID
    }
    
    init(name: String, tracks_url: String, image_url: String, sID: String) {
        self.name = name
        self.tracks_url = tracks_url
        self.image_url = image_url
        self.description = ""
        self.visible = -1
        self.sID = sID
    }
    
    func addTracks(_ songs: [Song]) {
        func asyncAddTracks(_ songs: [Song]) {
            DispatchQueue.main.async {
                self.tracks.append(contentsOf: songs)
                self.syncDownloadStatus()
            }
        }
        
        if let album = self as? Twib_Music.Album {
            let query = album.getQuery(songs)
            let url = "https://api.spotify.com/v1/tracks?ids=\(query)"
            SpotifyAPI.add_isrc(songs, url: url) { results in
                if let songs = results {
                    asyncAddTracks(songs)
                }
            }
        }
        else {
            asyncAddTracks(songs)
        }
    }
    
    // MARK: DOWNLOAD STATUS
    func getStatusIcon() -> String {
        switch self.downloadStatus {
        case "Not downloaded":
            return "arrow.down.circle"
        case "in progress":
            return "arrow.down.circle.dotted"
        case "complete":
            return "arrow.down.circle.fill"
        default:
            return "arrow.down.app.dashed.trianglebadge.exclamationmark"
        }
    }
    
    func setDownloadStatus(_ status: String) {
        DispatchQueue.main.async {
            self.downloadStatus = status
            self.downloadStatusIcon = self.getStatusIcon()
        }
    }
    
    func syncDownloadStatus() {
        let addToExpectedDownloadSize = (self.expectedDownloadSize == nil)
        var total_ms_duration = 0
        DispatchQueue.main.async {
            var allDownloaded = true
            for (i, track) in self.tracks.enumerated() {
                track.syncDownloadStatus()
                track.twibIdx = i
                total_ms_duration += addToExpectedDownloadSize ? track.duration : 0
                if !track.isDownloaded {
                    allDownloaded = false
                }
            }
            self.setDownloadStatus(allDownloaded ? "complete" : "Not downloaded")
            if addToExpectedDownloadSize {
                self.setExpectedDownloadSize(total_ms_duration)
            }
        }
    }
    
    func setExpectedDownloadSize(_ durationMs: Int) {
        let btyesPerSecond = 16000.0 // 16,000 bytes (16 KB)
        let durationSeconds = Double(durationMs) / 1000.0
        self.expectedDownloadSize = Int64(durationSeconds * btyesPerSecond)
    }
    
    // MARK: DOWNLOAD
    func createRequestBody() {
        self.requestBody["metadata"] = self.tracks.map { song in
            return [
                "isrc": song.external_ids["isrc"] as? String ?? "",
                "sID": song.sID,
                "name": song.name,
                "artist": song.artist,
                "album": song.album,
                "other_artists": song.others,
                "duration": song.duration,
                "track_number": song.track_number,
                "explicit": song.explicit
            ]
        }
    }
    
    func downloadTracks() {
        if self.downloadStatus == "complete" {
            return
        }
        
        DispatchQueue.main.async {
            self.downloadProgress = 0.0
            self.setDownloadStatus("in progress")
        }
        if self.requestBody.isEmpty {
            self.createRequestBody()
        }
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self.requestBody, options: .prettyPrinted)
            TwibServerAPI.downloadPlaylist(jsonData, expectedSize: self.expectedDownloadSize!, completion: { success in
                success ? self.syncDownloadStatus() : self.setDownloadStatus("failed")
            }, progress: { progress in
                DispatchQueue.main.async {
                    self.downloadProgress = min(progress, 1.0)
                }
            })
        } catch {
            print("Failed to serialize the JSON: \(error.localizedDescription)")
            syncDownloadStatus()
        }
    }
}

