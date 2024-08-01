//
//  SpotifyService.swift
//  Twib Music
//
//  Created by Lukas Cao on 7/31/24.
//

import Foundation

class MySpotifyInterfacer: ObservableObject {
    private var accessToken: String = ""
    private var refreshToken: String = ""
    private var expirationDate: Date = Date()
    
    func saveSession(_ session: SPTSession) {
        self.accessToken = session.accessToken
        self.refreshToken = session.refreshToken
        self.expirationDate = session.expirationDate
        self.fetchPlaylists()
    }
    
    func handleReponse(_ response: HTTPURLResponse) -> Bool {
        let code = response.statusCode
        switch code {
        case 200:
            print("Status \(code)")
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
    
    func satisfyRequest(_ request: URLRequest, completion: @escaping (Data?) -> Void) {
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
                completion(nil); return
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
    
    func parsePlaylists(_ playlists: Array<Dictionary<String, Any>>) {
        for playlist in playlists {
            guard let name = playlist["name"] as? String else { return }
            guard let description = playlist["description"] as? String else { return }
            guard let tracks = playlist["tracks"] as? Dictionary<String, Any> else { return }
            guard let tracks_url = tracks["href"] as? String else { return }
            guard let images = playlist["images"] as? [Dictionary<String, Any>] else { return }
            guard let image_url = images.first?["url"] as? String else { return }
            guard let visible = playlist["public"] as? Int else { return }
            print("Name: \(name), Description \(description), Tracks URL: \(tracks_url), Image URL: \(image_url), Visible: \(visible)")
        }
    }
    
    func fetchPlaylists() {
        // Setup Request
        guard let url = URL(string: "https://api.spotify.com/v1/me/playlists?limit=50&offset=0") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        // Big Stuff
        self.satisfyRequest(request) { data in
            guard let data = data else { return }
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                if let playlists = json["items"] as? [[String: Any]] {
                    self.parsePlaylists(playlists)
                }
                else {
                    print("Failed to get items from JSON data")
                }
            }
            else {
                print("Failed to parse the JSON data")
            }
        }
    }
}

struct UserProfile: Codable {
    let display_name: String
    let email: String
}

var Interfacer = MySpotifyInterfacer()
