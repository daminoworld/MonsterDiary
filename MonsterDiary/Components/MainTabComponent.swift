//
//  MainTabView.swift
//  MonsterDiary
//
//  Created by Damin on 4/13/24.
//

import SwiftUI

struct MainTabComponent: View {
    @EnvironmentObject var audioManager: AudioRecorderManager

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color(hex: "252525", alpha: 0.9))
                .opacity(0.9)
            HStack {
                Button(action: {
                    audioManager.toggleRecording()
                }) {
                    Image("record_ring")
                        .overlay {
                            Image(audioManager.isRecording ? "record_spuare" : "record_circle")
                                .animation(nil)
                        }
                }
                
                Spacer()
                
                Button(action: {
                    audioManager.isShowingRecordListView = true
                }) {
                    Image("history")
                }
            }
            .padding(.trailing, 40)
            .padding(.leading, 167)
            .padding(.bottom)
        }
    }
}



#Preview {
    MainTabComponent()
        .environmentObject(AudioRecorderManager())
}
