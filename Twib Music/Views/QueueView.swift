//
//  QueueView.swift
//  Twib Music
//
//  Created by Lukas Cao on 8/26/24.
//

import SwiftUI
import UIKit

let gradientImage: UIImage? = createGradientImage(size: CGSize(width: 600, height: 1000))

struct QueueView: View {
    @StateObject private var queueManager = QueueManager
    var body: some View {
        VStack {
            Text(queueManager.songQueue.isEmpty ? "Queue is Empty" : "Queue")
                .font(.custom("Helvetica", size: 24))
                .fontWeight(.medium)
                .padding(EdgeInsets(top: 12, leading: 0, bottom: 0, trailing: 0))
            if !queueManager.songQueue.isEmpty {
                Divider()
                List(Array(queueManager.songQueue.enumerated()), id: \.offset) { idx, song in
                    VStack(alignment: .leading) {
                        Text(song.name)
                            .font(.custom("Helvetica", size: 16))
                            .padding(.bottom, 2)
                            .lineLimit(1)
                        Text(song.artist)
                            .font(.custom("Helvetica", size: 12))
                            .fontWeight(.light)
                            .lineLimit(1)
                    }
                    .listRowBackground(Color.clear)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            queueManager.removeFromQueue(idx)
                        } label: {
                            Image(systemName: "trash")
                        }
                    }
                }
                .listStyle(.plain)
                .padding(EdgeInsets(top: 0, leading: 12, bottom: 12, trailing: 36))
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Image(uiImage: gradientImage ?? UIImage())
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
        )
    }
}

#Preview {
    QueueView()
}

func createGradientImage(size: CGSize) -> UIImage? {
    let gradientLayer = CAGradientLayer()
    gradientLayer.frame = CGRect(origin: .zero, size: size)
    gradientLayer.colors = [
        UIColor(red: 255.0 / 255.0, green: 252.0 / 255.0, blue: 121.0 / 255.0, alpha: 1.0).cgColor,
        UIColor(red: 118.0 / 255.0, green: 214.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0).cgColor,
        UIColor(red: 255.0 / 255.0, green: 252.0 / 255.0, blue: 121.0 / 255.0, alpha: 1.0).cgColor
    ]
    gradientLayer.locations = [0, 0.5, 1]

    UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
    gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return image
}
