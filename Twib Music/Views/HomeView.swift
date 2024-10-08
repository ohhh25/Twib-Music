//
//  HomeView.swift
//  Twib Music
//
//  Created by Lukas Cao on 7/3/24.
//

import SwiftUI

fileprivate let buttonBackgroundColor = Color(red:(29.0 / 255.0), green:(185.0 / 255.0), blue:(84.0 / 255.0))
fileprivate let topColor = Color(red:(118.0 / 255.0), green:(214.0 / 255.0), blue:(255.0 / 255.0))
fileprivate let botColor = Color(red:(255.0 / 255.0), green:(252.0 / 255.0), blue:(121.0 / 255.0))
fileprivate let grad = [botColor, topColor, botColor, topColor, topColor]

struct HomeView: View {
    @StateObject private var spotifyManager = SpotifyManager
    init() {
        UITabBar.appearance().unselectedItemTintColor = UIColor.gray
    }
    
    var body: some View {
        Group {
            if !spotifyManager.sessionConnected {
                HeadingView()
                    .foregroundStyle(.black)
                Image("Icon")
                    .resizable()
                    .padding(.top, 12)
                    .scaledToFit()
                Button("Connect Spotify Account", systemImage: "arrow.up.forward.app") {
                    spotifyManager.didTapConnect()
                }
                .font(.custom("Helvetica", size: 18))
                .foregroundColor(.white)
                .padding(EdgeInsets(top: 14, leading: 28, bottom: 14, trailing: 28))
                .background(buttonBackgroundColor)
                .cornerRadius(32)
                .padding(.top, 24)
                Spacer()
            }
            else {
                TabView {
                    LibraryView().tabItem {
                        Label("Home", systemImage: "house.fill")
                    }.tag(1)
                    PlayingView().tabItem {
                        Label("Playing", systemImage: "waveform")
                    }.tag(2)
                    QueueView().tabItem {
                        Label("Queue", systemImage: "music.note.list")
                    }.tag(3)
                    SettingsView().tabItem {
                        Label("Settings", systemImage: "gear")
                    }
                }
            }
        }
        .background(AngularGradient(colors: grad, center: UnitPoint(x: 0.5, y: 0.4)))
        .onAppear {
            if !SpotifyManager.sessionConnected {
                spotifyManager.restoreSession()
            }
        }
    }
}

#Preview {
    HomeView()
}
