import SwiftUI

struct HomeView: View {
    @EnvironmentObject var audioManager: AudioRecorderManager
    @State private var isShowingList: Bool = false
    var body: some View {
        ZStack {
            ARViewContainer().ignoresSafeArea(.all)
            Color.white

            VStack {
                MainDateComponent()
                    .padding(20)
                
                Spacer()
                
                AudioPlayingComponent()
                    .frame(width: 114, height: 114)
                
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
