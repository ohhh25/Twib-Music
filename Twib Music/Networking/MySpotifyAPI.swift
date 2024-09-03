//
//  MySpotifyAPI.swift
//  Twib Music
//
//  Created by Lukas Cao on 7/31/24.
//

import Foundation

var SpotifyAPI = MySpotifyAPI()

class MySpotifyAPI: ObservableObject {
    @Published var playlists: [Playlist] = []
    @Published var albums: [Album] = []
    
    private var Session: SPTSession?
    private var accessToken: String = ""
    private var refreshToken: String = ""
    
    // MARK: BASIC INIT
    init() {
        self.playlists = [Playlist(name: "Liked Songs", description: "",
                                   tracks_url: "https://api.spotify.com/v1/me/tracks",
                                   image_url: "https://raw.githubusercontent.com/ohhh25/Twib-Music/main/Twib%20Music/Assets.xcassets/saved.imageset/saved.png",
                                   visible: -1, sID: "THE_GREATEST_TWIB")]
        self.albums = []
    }
    
    func saveSession(_ session: SPTSession) {
        self.Session = session
        self.accessToken = session.accessToken
        self.refreshToken = session.refreshToken
        if self.playlists.count == 1 && self.albums.isEmpty {
            self.fetchPlaylists(url: "https://api.spotify.com/v1/me/playlists?limit=50")
            self.fetchAlbums(url: "https://api.spotify.com/v1/me/albums?limit=50")
        }
    }
    
    // MARK: HELPER FUNCTIONS
    func handleReponse(_ response: HTTPURLResponse) -> Bool {
        let code = response.statusCode
        switch code {
        case 200:
            return true
        case 401:
            print("Status \(code): Bad or expired token. This can happen if the user revoked a token or the access token has expired. You should re-authenticate the user.")
            return false
        case 403:
            print("Status \(code): Bad OAuth request (wrong consumer key, bad nonce, expired timestamp...). Unfortunately, re-authenticating the user won't help here.")
            return false
        case 429:
            print("Status \(code): The app has exceeded its rate limits.")
            return false
        default:
            print("Status \(code)")
            return false
        }
    }
    
    func checkSession() {
        if let session = self.Session {
            if session.isExpired {
                print("Session Expired. Renewing...")
                SpotifyManager.sessionManager.renewSession()
            }
        }
    }
    
    func satisfyRequest(_ request: URLRequest, retryCount: Int = 0, completion: @escaping (Data?) -> Void) {
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Return if error exists
            if let error = error {
                print("Some Error: \(error.localizedDescription)")
                completion(nil); return
            }
            // Return if response is not HTTP
            guard let httpResponse = response as? HTTPURLResponse else {
                print("No HTTP response")
                completion(nil); return
            }
            // Check Status Code
            if !self.handleReponse(httpResponse) {
                if httpResponse.statusCode == 429 {
                    if retryCount < 2 {
                        let delay = DispatchTime.now() + .seconds(2)
                        DispatchQueue.global().asyncAfter(deadline: delay) {
                            self.satisfyRequest(request, retryCount: retryCount + 1, completion: completion)
                        }
                    } else {
                        print("Max retry attempts reached.")
                        completion(nil); return
                    }
                } else {
                    completion(nil); return
                }
            }
            // Check If Data was Received
            guard let data = data else {
                print("No data received")
                completion(nil); return
            }
            completion(data)
        }
        task.resume()
    }
    
    // MARK: PLAYLISTS METADATA
    func parsePlaylists(_ array: [[String: Any]]) -> [Playlist] {
        let parsedPlaylists = array.compactMap { playlist -> Playlist? in
            guard
                let name = playlist["name"] as? String,
                let description = playlist["description"] as? String,
                let tracks = playlist["tracks"] as? [String: Any],
                let tracks_url = tracks["href"] as? String,
                let images = playlist["images"] as? [[String: Any]],
                let image_url = images.first?["url"] as? String,
                // unique
                let sID = playlist["id"] as? String
            else {
                return nil
            }
            let visible = (playlist["public"] as? Int) ?? -1
            return Playlist(name: name, description: description,
                            tracks_url: tracks_url, image_url: image_url,
                            visible: visible, sID: sID)
        }
        return parsedPlaylists
    }
    
    func fetchPlaylists(url: String) {
        // Setup Request
        guard let url = URL(string: url) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        // Big Stuff
        self.satisfyRequest(request) { data in
            guard let data = data else { return }
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                if let items = json["items"] as? [[String: Any]] {
                    // pass an array of dictionaries get an array of Playlist struct
                    DispatchQueue.main.async {
                        self.playlists.append(contentsOf: self.parsePlaylists(items))
                        print("\(self.playlists.count) Playlists fetched")
                    }
                }
                else {
                    print("Failed to get items from JSON data")
                }
                if let next = json["next"] as? String {
                    self.fetchPlaylists(url: next)
                }
            }
            else {
                print("Failed to parse the JSON data")
            }
        }
    }
    
    // MARK: ALBUMS METADATA
    func parseAlbums(_ array: [[String: Any]]) -> [Album] {
        let parsedAlbums: [Album] = array.compactMap { item -> Album? in
            guard
                let album = item["album"] as? [String: Any],
                // inherited values
                let name = album["name"] as? String,
                let tracks = album["tracks"] as? [String: Any],
                let tracks_url = tracks["href"] as? String,
                let images = album["images"] as? [[String: Any]],
                let image_url = images.first?["url"] as? String,
                // extended values
                let artists = album["artists"] as? [[String: Any]],
                let type = album["album_type"] as? String,
                let total_tracks = album["total_tracks"] as? Int,
                let release_date = album["release_date"] as? String,
                let external_ids = album["external_ids"] as? [String: Any],
                let popularity = album["popularity"] as? Int,
                // unique
                let sID = album["id"] as? String
            else {
                return nil
            }
            return Album(name: name, tracks_url: tracks_url, image_url: image_url,
                         artists: artists, type: type, total_tracks: total_tracks,
                         release_date: release_date, external_ids: external_ids,
                         popularity: popularity, sID: sID)
        }
        return parsedAlbums
    }
    
    func fetchAlbums(url: String) {
        // Setup Request
        guard let url = URL(string: url) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        // Big Stuff
        self.satisfyRequest(request) { data in
            guard let data = data else { return }
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                if let items = json["items"] as? [[String: Any]] {
                    DispatchQueue.main.async {
                        self.albums.append(contentsOf: self.parseAlbums(items))
                        print("\(self.albums.count) Albums fetched")
                    }
                }
                else {
                    print("Failed to get items from JSON data")
                }
                if let next = json["next"] as? String {
                    self.fetchAlbums(url: next)
                }
            }
            else {
                print("Failed to parse the JSON data")
            }
        }
    }
    
    // MARK: TRACKS METADATA
    func parseTracks(_ array: [[String: Any]], isAlbum: Bool) -> [Song] {
        let songs: [Song] = array.compactMap { item -> Song? in
            guard let song = isAlbum ? item : item["track"] as? [String: Any] else { return nil }
            let local = song["is_local"] as? Int
            if local == 1 {
                return nil
            }
            guard
                let name = song["name"] as? String,
                let artists = song["artists"] as? [[String: Any]],
                let album = (isAlbum) ? [:] : song["album"] as? [String: Any],
                let track_number = song["track_number"] as? Int,
                let duration = song["duration_ms"] as? Int,
                let sID = song["id"] as? String
            else {
                return nil
            }
            let external_ids = song["external_ids"] as? [String: Any] ?? [:]
            let preview_url = (song["preview_url"] as? String) ?? ""
            let explicit = (song["explicit"] as? Int) ?? -1
            let popularity = song["popularity"] as? Int ?? -1
            return Song(name: name, artists: artists, album: album,
                        track_number: track_number, duration: duration,
                        sID: sID, external_ids: external_ids,
                        preview_url: preview_url, explicit: explicit,
                        popularity: popularity)
        }
        return songs
    }
    
    func fetchTracks(_ playlist: Playlist, url: String) {
        // Setup Request
        guard let url = URL(string: url) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        // Big Stuff
        self.satisfyRequest(request) { data in
            guard let data = data else { return }
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                if let items = json["items"] as? [[String: Any]] {
                    let tracks = self.parseTracks(items, isAlbum: playlist is Twib_Music.Album)
                    playlist.addTracks(tracks)
                }
                else {
                    print("Failed to get items from JSON data")
                }
                if let next = json["next"] as? String {
                    self.fetchTracks(playlist, url: next)
                }
            }
            else {
                print("Failed to parse the JSON data")
            }
        }
    }
    
    // MARK: ISRC FOR ALBUM TRACKS
    func add_isrc(_ tracks: [Song], url: String, completion: @escaping ([Song]?) -> Void){
        // Setup Request
        guard let url = URL(string: url) else { completion(nil); return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        self.satisfyRequest(request) { data in
            guard let data else { completion(nil); return }
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                if let items = json["tracks"] as? [[String: Any]] {
                    let eIDs = items.map { item in
                        return item["external_ids"] as? [String: Any] ?? [:]
                    }
                    zip(eIDs, tracks).forEach { (eID, track) in
                        track.external_ids = eID
                    }
                    completion(tracks)
                    return
                } else {
                    print("Failed to get tracks from JSON data")
                    completion(nil)
                    return
                }
            } else {
                print("Failed to parse the JSON data")
                completion(nil)
                return
            }
        }
    }
}
