import SwiftUI

struct HomeView: View {
//    @ObservedObject var audioRecorder = AudioRecorderManager()
    @EnvironmentObject var audioRecorder: AudioRecorderManager
    @State private var isShowingList: Bool = false
    var body: some View {
        ZStack {
            ARViewContainer()
                .ignoresSafeArea(.all)
            VStack {
                MainDateComponent()
                Spacer()
                Button(action: {
                    self.audioRecorder.isRecording ? self.audioRecorder.stopRecording() : self.audioRecorder.startRecording()
                }) {
                    Text(self.audioRecorder.isRecording ? "녹음 정지" : "녹음 시작")
                        .foregroundColor(.white)
                        .background(self.audioRecorder.isRecording ? Color.red : Color.blue)
                        .clipShape(Capsule())
                        .padding()
                }
                
                Button {
                    isShowingList = true
                } label: {
                    Text("리스트")
                        .background(Color.blue)
                        .padding()
                }
                .sheet(isPresented: $isShowingList, content: {
                    RecordingListView()
                })
            }
        }
        
    }
}

#Preview {
    HomeView()
}
