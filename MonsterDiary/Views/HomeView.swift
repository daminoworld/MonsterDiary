import SwiftUI

struct HomeView: View {
    @EnvironmentObject var audioManager: AudioRecorderManager
    @EnvironmentObject var arManager: ARModelManager

    @State private var recordingName: String = ""
    let arViewContainer = ARViewContainer()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                arViewContainer.ignoresSafeArea(.all)
                
                VStack {
                    MainDateComponent()
                        .padding(20)
                    
                    Spacer()
                    
                    if audioManager.isRecording {
                        AudioPlayingComponent()
                            .frame(width: 114, height: 114)
                        
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(hex: "252525", alpha: 0.9))
                            .opacity(0.9)
                            .frame(width: 100, height: 40)
                            .overlay {
                                Text("\(audioManager.timerString)")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                            }
                            .padding(.top, 30)
                    }
                    
                    Spacer()
                    Spacer()
                }
                .alert("일기 제목을 입력해주세요", isPresented: $audioManager.showingAlert) {
                    TextField("\(Date().toString(dateFormat: "yyyy.MM.dd '일기'"))", text: $recordingName)
                    Button("저장") {
                        audioManager.showingAlert = false
                    }
                } message: {
                    Text("최대 15자 이내로 입력해주세요")
                }
                
                // deprecated 됐는데 쓰라고 하는 init과 차이가 없는데 어떻게 구분?
                .onChange(of: audioManager.showingAlert) { newValue in
                    // alert이 꺼질때만 실행
                    if !newValue  {
                        audioManager.saveRecording(with: recordingName)
                        recordingName = ""
                    }
                }
                
                
                
                MainTabComponent()
                    .ignoresSafeArea()
                    .frame(height: 134)
                
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            
            
        }
         
    }
}

#Preview {
    HomeView()
        .environmentObject(AudioRecorderManager())
}
