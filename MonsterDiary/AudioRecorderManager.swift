//
//  AudioRecorderManager.swift
//  MonsterDiary
//
//  Created by Damin on 4/12/24.
//

import Foundation
import AVFoundation

class AudioRecorderManager : NSObject, ObservableObject{
    
    var audioRecorder : AVAudioRecorder!
    var audioPlayer : AVAudioPlayer!
    var recordBarTimer: Timer?

    @Published var audioLevels: [CGFloat] = [0.5, 0.3, 0.6, 0.4, 0.7, 0.2, 0.5]
    @Published var isRecording : Bool = false
    @Published var isPlaying: Bool = false
    @Published var recordingsList = [Recording]()
    @Published var isShowingRecordListView: Bool = false
    @Published var hasRecordFinished: Bool = false
    @Published var showingAlert: Bool = false
    var indexOfPlayer = 0
    
    @Published var countSec = 0
    @Published var timerCount : Timer?
    @Published var timerString : String = "0:00"
    
    var playingURL : URL?
    
    override init(){
        super.init()
        
        fetchAllRecording()
        
    }

    func startRecording() {
        
        let recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
        } catch {
            print("Cannot setup the Recording")
        }
        
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = path.appendingPathComponent("\(Date().toString(dateFormat: "YY-MM-dd 'at' HH:mm:ss")).m4a")
        
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        
        do {
            audioRecorder = try AVAudioRecorder(url: fileName, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder.prepareToRecord()
            audioRecorder.record()
            isRecording = true
            
            timerCount = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (value) in
                self.countSec += 1
                self.timerString = self.covertSecToMinAndHour(seconds: self.countSec)
            })
            
        } catch {
            print("Failed to Setup the Recording")
        }
        
        
        startUpdatingAudioLevels()
    }
    
    
    func stopRecording(){
        
        audioRecorder.stop()
        isRecording = false
        stopUpdatingAudioLevels()

        
        self.countSec = 0
        timerCount!.invalidate()
        
        
    }
    
    func startUpdatingAudioLevels() {
        recordBarTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateAudioLevels()
        }
    }

    func updateAudioLevels() {
        audioRecorder?.updateMeters()

        // 실제 오디오 레벨을 얻습니다.
          if let averagePower = audioRecorder?.averagePower(forChannel: 0) {
              let baseLevel = CGFloat(max(0.2, pow(10.0, averagePower / 20)))  // 데시벨 값을 선형 스케일로 변환

//              // 기본 레벨을 사용하여 각 막대의 높이를 조금씩 다르게 합니다.
//              audioLevels = (0..<10).map { _ in
//                  let randomVariance = CGFloat.random(in: 0.8...1.2)  // 무작위 변형 범위
//                  return CGFloat(baseLevel) * randomVariance
//              }
              
              // 기본 레벨을 사용하여 각 막대의 높이를 조금씩 다르게 합니다.
              // 무작위 변형을 적용할 때 더 큰 범위를 사용합니다.
              audioLevels = audioLevels.enumerated().map { index, previousLevel in
                  let randomVariance = CGFloat.random(in: 0.5...1.5)  // 무작위 변형 범위 확장
                  let targetLevel = baseLevel * randomVariance
                  
                  // 현재 레벨과 목표 레벨 사이를 부드럽게 전환
                  // 변화 속도를 늦추거나 빠르게 조절하여 더 동적인 효과를 줄 수 있습니다.
                  return previousLevel * 0.5 + targetLevel * 0.8  // 더 빠른 변화를 위해 비율 조정
              }
          }
    }

    func stopUpdatingAudioLevels() {
        recordBarTimer?.invalidate()
        audioLevels = [0.5, 0.3, 0.6, 0.4, 0.7, 0.2, 0.5]
    }
    
    
    func fetchAllRecording(){
        
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let directoryContents = try! FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil)

        for i in directoryContents {
            recordingsList.append(Recording(fileURL : i, createdAt:getFileDate(for: i), isPlaying: false))
        }
        
        recordingsList.sort(by: { $0.createdAt.compare($1.createdAt) == .orderedDescending})
        
    }
    
    
    func startPlaying(url : URL) {
        
        playingURL = url
        
        let playSession = AVAudioSession.sharedInstance()
        
        do {
            try playSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        } catch {
            print("Playing failed in Device")
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            
            for i in 0..<recordingsList.count {
                if recordingsList[i].fileURL == url {
                    recordingsList[i].isPlaying = true
                }
            }
            
        } catch {
            print("Playing Failed")
        }
        
        
    }
    
    func stopPlaying(url : URL) {
        
        audioPlayer.stop()
        
        for i in 0..<recordingsList.count {
            if recordingsList[i].fileURL == url {
                recordingsList[i].isPlaying = false
            }
        }
    }
    
 
    func deleteRecording(url : URL) {
        
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            print("Can't delete")
        }
        
        for i in 0..<recordingsList.count {
            
            if recordingsList[i].fileURL == url {
                if recordingsList[i].isPlaying == true{
                    stopPlaying(url: recordingsList[i].fileURL)
                }
                recordingsList.remove(at: i)
                
                break
            }
        }
    }
    
    
    func getFileDate(for file: URL) -> Date {
        if let attributes = try? FileManager.default.attributesOfItem(atPath: file.path) as [FileAttributeKey: Any],
            let creationDate = attributes[FileAttributeKey.creationDate] as? Date {
            return creationDate
        } else {
            return Date()
        }
    }
}

extension AudioRecorderManager {
    func covertSecToMinAndHour(seconds : Int) -> String{
        
        let (_,m,s) = (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
        let sec : String = s < 10 ? "0\(s)" : "\(s)"
        return "\(m):\(sec)"
        
    }
}

extension AudioRecorderManager: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        hasRecordFinished = true
    }
}

extension AudioRecorderManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
       
        for i in 0..<recordingsList.count {
            if recordingsList[i].fileURL == playingURL {
                recordingsList[i].isPlaying = false
            }
        }
    }
}
