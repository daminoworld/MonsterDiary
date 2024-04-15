import SwiftUI

struct HomeView: View {
    @EnvironmentObject var audioManager: AudioRecorderManager
    @State private var isShowingList: Bool = false
    @State private var recordingName: String = ""
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
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
                                .frame(width: 100, height: 40)
                                .overlay {
                                    Text("\(audioManager.timerString)")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.white)
                                }
                                .padding(.top, 30)
                        }
                        .offset(y: -20)
                    }
                    Spacer()
                }
                .alert("일기 제목을 입력해주세요", isPresented: $audioManager.showingAlert) {
                    TextField("오늘의 일기", text: $recordingName)
                    Button("저장") {

                        if recordingName.isEmpty {
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy.MM.dd"
                            recordingName = "\(dateFormatter.string(from: Date())) 일기"
                        }
                        audioManager.recordingName = recordingName // AudioRecorderManager에 제목 업데이트
                        print("저장된 제목: \(recordingName)")
                        recordingName = ""
                        audioManager.showingAlert = false
                    }
                } message: {
                    Text("최대 15자 이내로 입력해주세요")
                }
                
                
                
                MainTabComponent()
                    .ignoresSafeArea()
                    .frame(height: 134)
                
            }
            .sheet(isPresented: $isShowingList) {
                RecordingListView()
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            
            
        }
        
    }
}

#Preview {
    HomeView()
        .environmentObject(AudioRecorderManager())
}
