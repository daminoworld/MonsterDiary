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
            HStack(alignment: .bottom, spacing: 2) {
                ForEach(audioManager.audioLevels.indices, id: \.self) { index in
                    Rectangle()
                        .frame(width: 20, height: audioManager.audioLevels[index] * 200) // 예를 들어 최대 높이는 200
                        .animation(.easeInOut, value: audioManager.audioLevels[index])
                }
            }
            .onAppear {
            }
            .onDisappear {
            }
        }
}

#Preview {
    AudioPlayingComponent()
}
