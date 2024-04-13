import SwiftUI

struct HomeView: View {
    @EnvironmentObject var audioManager: AudioRecorderManager
    @State private var isShowingList: Bool = false
    var body: some View {
        ZStack {
            ARViewContainer().ignoresSafeArea(.all)

            VStack {
                MainDateComponent()
                    .padding(20)
                
                Spacer()
                
                if audioManager.isRecording {
                    VStack {
                        AudioPlayingComponent()
                            .frame(width: 114, height: 114)
                        
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(hex: "252525", alpha: 0.9))
                            .opacity(0.9)
                            .frame(width: 179, height: 32)
                            .overlay {
                                Text("오늘의 일기 생성중...")
                                    .foregroundStyle(.white)
                            }
                            .padding(.top, 30)
                    }
                }
                
                Spacer()
                
                MainTabComponent()
                    .ignoresSafeArea()
                    .frame(height: 137)

                .sheet(isPresented: $isShowingList, content: {
                    RecordingListView()
                })
            }
        }
        
    }
}

#Preview {
    HomeView()
        .environmentObject(AudioRecorderManager())
}
