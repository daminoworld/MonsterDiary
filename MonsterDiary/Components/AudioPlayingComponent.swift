//
//  AudioPlayingComponent.swift
//  MonsterDiary
//
//  Created by Damin on 4/12/24.
//

import SwiftUI

struct AudioPlayingComponent: View {
    @EnvironmentObject var audioManager: AudioRecorderManager
    
    var body: some View {
            HStack(alignment: .center, spacing: 8) {
                ForEach(audioManager.audioLevels.indices, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 25.0)
                        .fill(.white)
                        .frame(width: 10, height: audioManager.audioLevels[index] * 100)
                        .animation(.easeInOut, value: audioManager.audioLevels[index])
                }
            }
//            .padding(40)
            .background {
                Circle()
                    .fill(Color(hex: "252525", alpha: 0.9))
                    .opacity(0.9)
                    .frame(width: 150, height: 150)
            }
            .onAppear {
            }
            .onDisappear {
            }
        }
}

#Preview {
    AudioPlayingComponent()
        .environmentObject(AudioRecorderManager())
}
