//
//  RecordingHistoryView.swift
//  MonsterDiary
//
//  Created by Damin on 4/15/24.
//

import SwiftUI

struct RecordingHistoryView: View {
    @EnvironmentObject var audioManager: AudioRecorderManager

    var body: some View {
        NavigationView {
            List {
                ForEach($audioManager.recordingsList, id: \.fileURL) { $recording in
                    HStack {
                        Text(recording.fileURL.lastPathComponent)
                        Spacer()
                        Button(action: {
                            if recording.isPlaying == true {
                                audioManager.stopPlaying(url: recording.fileURL)
                            }else{
                                audioManager.startPlaying(url: recording.fileURL)
                            }
                        }) {
                            Image(systemName: recording.isPlaying ? "pause.circle" : "play.circle")
                                .foregroundColor(.white)
                                .font(.system(size:30))
                        }
                    }
                }
                .onDelete(perform: audioManager.deleteRecording)
            }
            .navigationBarTitle("History")
            .onAppear(perform: audioManager.fetchRecordings)
            
        }
    }
}


#Preview {
    RecordingHistoryView()
        .environmentObject(AudioRecorderManager())
}
