//
//  MySpotifyManager.swift
//  Twib Music
//
//  Created by Lukas Cao on 7/21/24.
//

import Combine
import SpotifyiOS

class MySpotifyManager: NSObject, SPTSessionManagerDelegate, ObservableObject {
    // MARK: Basic Variables
    @Published var sessionConnected: Bool = false
    
    private let SpotifyClientID = "94c1f2b813ae49f1add24416dab05b6c"
    private let SpotifyRedirectURI = URL(string: "Twib-Music://spotify-login-callback")!
    private var connectionCallback: ((Bool) -> Void)?
    
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
    
    // MARK: Actions
    @objc func didTapConnect() {
        let scope: SPTScope = [.userLibraryRead, .playlistReadPrivate]
        sessionManager.initiateSession(with: scope, options: .clientOnly, campaign: nil)
    }
    
    func handleOpenUrl(_ url: URL) {
        sessionManager.application(UIApplication.shared, open: url, options: [:])
    }
}

var SpotifyManager = MySpotifyManager()
