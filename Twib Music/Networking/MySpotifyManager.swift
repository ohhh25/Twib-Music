//
//  MySpotifyManager.swift
//  Twib Music
//
//  Created by Lukas Cao on 7/21/24.
//

import Combine
import SpotifyiOS

var SpotifyManager = MySpotifyManager()

class MySpotifyManager: NSObject, SPTSessionManagerDelegate, ObservableObject {
    // MARK: Basic Variables
    @Published var sessionConnected: Bool = false
    
    private let SpotifyClientID = "94c1f2b813ae49f1add24416dab05b6c"
    private let SpotifyRedirectURI = URL(string: "Twib-Music://spotify-login-callback")!
    
    lazy var configuration: SPTConfiguration = {
        let configuration = SPTConfiguration(clientID: SpotifyClientID, redirectURL: SpotifyRedirectURI)
        return configuration
    }()
    
    lazy var sessionManager: SPTSessionManager = {
        let manager = SPTSessionManager(configuration: configuration, delegate: self)
        return manager
    }()
    
    // MARK: Session-Related
    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
        print("session failed with error: ", error)
        DispatchQueue.main.async {
            self.sessionConnected = false
        }
    }

    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        print("session initated")
        SpotifyAPI.saveSession(session)
        DispatchQueue.main.async {
            self.sessionConnected = true
        }
    }
    
    func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
        print("session renewed")
        SpotifyAPI.saveSession(session)
    }
    
    // MARK: Actions
    @objc func didTapConnect() {
        let scope: SPTScope = [.userLibraryRead, .playlistReadPrivate]
        sessionManager.initiateSession(with: scope, options: .clientOnly, campaign: nil)
    }
    
    func handleOpenUrl(_ url: URL) {
        sessionManager.application(UIApplication.shared, open: url, options: [:])
    }
}
