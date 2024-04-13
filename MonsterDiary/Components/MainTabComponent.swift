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
                Button {
                audioManager.isRecording ? audioManager.stopRecording() : audioManager.startRecording()
                    
                } label: {
                    Image("record_ring")
                        .overlay {
                            Image(audioManager.isRecording ? "record_spuare" :"record_circle")
                                .animation(nil)
                        }
                }
                
                Spacer()
                
                Button {
                    if audioManager.isRecording {
                        audioManager.stopRecording()
                    }
                    audioManager.isShowingRecordListView = true
                } label: {
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
