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
    @ObservedObject private var queueManager = QueueManager

    var body: some View {
        VStack {
            // MARK: Heading Message
            Text(audioManager.isSong ? "Playing Song" : "No music playing")
                .font(.custom("Helvetica", size: 24))
                .fontWeight(.medium)
            
            // MARK: Song Image
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
            
            // MARK: Metadata
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
            
            // MARK: Playback Progress
            Slider(value: $audioManager.progress, in: 0...1)
                .padding(EdgeInsets(top: 24, leading: 0, bottom: 6, trailing: 0))
                .disabled(true)
            HStack {
                Text(audioManager.isSong ? timeFormatter(Int(audioManager.elapsedTime)) : "--:--")
                    .font(.custom("Helvetica", size: 16))
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(audioManager.isSong ? timeFormatter(audioManager.currentSong.duration / 1000) : "--:--")
                    .font(.custom("Helvetica", size: 16))
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.bottom, 24)
            
            // MARK: Playback controls
            HStack {
                Button("", systemImage: queueManager.shuffleMode ? "shuffle.circle.fill" : "shuffle.circle") {
                    QueueManager.updateQueue(!queueManager.shuffleMode)
                }
                .font(.custom("Helvetica", size: 36))
                .disabled(!audioManager.isSong)
                Spacer()
                Button("", systemImage: "backward.end.fill") {
                    audioManager.backToPreviousSong()
                }
                .disabled(queueManager.previousSongs.isEmpty && !audioManager.isSong)
                Spacer()
                Button("", systemImage: audioManager.isPlaying ? "pause.circle.fill" : "play.circle.fill") {
                    audioManager.togglePlayback()
                }
                .font(.custom("Helvetica", size: 72))
                .disabled(!audioManager.isSong)
                Spacer()
                Button("", systemImage: "forward.end.fill") {
                    audioManager.skipToNextSong()
                }
                .disabled(!audioManager.isSong)
                Spacer()
                Button("", systemImage: queueManager.repeatStatusIcon) {
                    QueueManager.handleRepeatStatus()
                }
                .font(.custom("Helvetica", size: 36))
                .disabled(!audioManager.isSong)
            }
            .font(.custom("Helvetica", size: 36))
            
            Spacer()
        }
        .padding(EdgeInsets(top: 12, leading: 24, bottom: 0, trailing: 24))
        .background(AngularGradient(colors: grad, center: UnitPoint(x: 0, y: 0)))
    }
}

#Preview {
    PlayingView()
}

func timeFormatter(_ seconds: Int) -> String {
    let formatter = DateComponentsFormatter()
    formatter.zeroFormattingBehavior = .pad
    formatter.allowedUnits = [.minute, .second]
    
    if let time = formatter.string(from: TimeInterval(seconds)) {
        return time
    }
    return "--:--"
}
