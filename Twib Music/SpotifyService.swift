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
    
    func satisfyRequest(_ request: URLRequest, completion: @escaping (String) -> Void) {
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Return if error exists
            if let error = error {
                print("Some Error: \(error.localizedDescription)")
                completion("")
            }
            // Return if response is not HTTP
            guard let httpResponse = response as? HTTPURLResponse else {
                print("No HTTP response")
                completion(""); return
            }
            // Check Status Code
            if !self.handleReponse(httpResponse) {
                completion("")
            }
            // Check If Data was Received
            guard let data = data else {
                print("No data received")
                completion(""); return
            }
            // Convert to UTF-8 string
            if let responseString = String(data: data, encoding: .utf8) {
                //print("Response data: \(responseString)")
                completion(responseString)
            } else {
                print("Failed to decode the data: The data could not be converted to a UTF-8 string.")
                completion("")
            }
        }
        task.resume()
    }
    
    func fetchPlaylists() {
        // Setup Request
        guard let url = URL(string: "https://api.spotify.com/v1/me/playlists") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        self.satisfyRequest(request) { data in
            if data != "" {
                print(data)
            }
        }
    }
}

struct UserProfile: Codable {
    let display_name: String
    let email: String
}

var Interfacer = MySpotifyInterfacer()