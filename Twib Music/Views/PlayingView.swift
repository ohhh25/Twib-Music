//
//  PlayingView.swift
//  Twib Music
//
//  Created by Lukas Cao on 8/26/24.
//

import SwiftUI

fileprivate let topColor = Color(red:(118.0 / 255.0), green:(214.0 / 255.0), blue:(255.0 / 255.0))
fileprivate let botColor = Color(red:(255.0 / 255.0), green:(252.0 / 255.0), blue:(121.0 / 255.0))
fileprivate let grad = [topColor, botColor, topColor]

struct PlayingView: View {
    @StateObject private var audioManager = AudioManager

    var body: some View {
        VStack {
            Text(audioManager.isSong ? "Playing Song" : "No music playing")
                .font(.custom("Helvetica", size: 24))
                .fontWeight(.medium)
            AsyncImage(url: URL(string: audioManager.currentSong.image_url)) { image in
                image.resizable()
                .scaledToFit()
                .padding(EdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0))
            } placeholder: {
                Image("none")
                    .resizable()
                    .scaledToFit()
                    .padding(EdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0))
            }
            Text(audioManager.currentSong.name)
                .font(.custom("Helvetica", size: 24))
                .fontWeight(.bold)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 72, alignment: .topLeading)
            Text(audioManager.currentSong.artist)
                .font(.custom("Helvetica", size: 18))
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
            ProgressView()
                .progressViewStyle(.linear)
                .padding(EdgeInsets(top: 24, leading: 0, bottom: 6, trailing: 0))
            HStack {
                Text(audioManager.isSong ? "0:00" :"--:--")
                    .font(.custom("Helvetica", size: 16))
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(audioManager.isSong ? "2:52" :"--:--")
                    .font(.custom("Helvetica", size: 16))
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.bottom, 24)
            HStack {
                Button("", systemImage: "shuffle") {
                    print("Shuffle Button Pressed")
                }
                .font(.custom("Helvetica", size: 24))
                Spacer()
                Button("", systemImage: "backward.end.fill") {
                    print("Previous Button Pressed")
                }
                Spacer()
                Button("", systemImage: audioManager.playing ? "pause.circle.fill" : "play.circle.fill") {
                    audioManager.togglePlayback()
                }
                .font(.custom("Helvetica", size: 72))
                Spacer()
                Button("", systemImage: "forward.end.fill") {
                    print("Next Button Pressed")
                }
                Spacer()
                Button("", systemImage: "repeat") {
                    print("Repeat Button Pressed")
                }
                .font(.custom("Helvetica", size: 24))
            }
            .font(.custom("Helvetica", size: 36))
            .disabled(!audioManager.isSong)
            Spacer()
        }
        .padding(EdgeInsets(top: 12, leading: 24, bottom: 0, trailing: 24))
        .background(AngularGradient(colors: grad, center: UnitPoint(x: 0, y: 0)))
    }
}

#Preview {
    PlayingView()
}
