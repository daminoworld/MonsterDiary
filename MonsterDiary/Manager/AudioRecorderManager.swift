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
    var countTimer : Timer?
    var weekRecording: [Int:Recording] = [:]
    
    @Published var audioLevels: [CGFloat] = [0.5, 0.3, 0.6, 0.4, 0.7, 0.2, 0.5]
    @Published var isRecording : Bool = false
    @Published var isPlaying: Bool = false
    @Published var recordingsList = [Recording]()
    @Published var isShowingRecordListView: Bool = false
    @Published var showingAlert: Bool = false
    @Published var countSec = 0
    @Published var timerString : String = "0:00"
    @Published var tempRecordingURL: URL? // 녹음을 임시로 저장할 URL
    @Published var weekRecordingList: [Recording] = []
    var playingURL : URL?
    
    override init(){
        super.init()
        
        fetchAllRecording()
        
    }
    
    

    func startRecording() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
        } catch {
            print("Failed to set up recording session")
        }

        let tempFileName = UUID().uuidString + ".m4a" // 임시 파일 이름 생성
        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let tempFileURL = documentPath.appendingPathComponent(tempFileName)
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: tempFileURL, settings: settings)
            audioRecorder.isMeteringEnabled = true
            audioRecorder.delegate = self
            audioRecorder.prepareToRecord()
            audioRecorder.record()
            tempRecordingURL = audioRecorder.url // 임시 파일 URL 저장
            countTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (value) in
                self.countSec += 1
                self.timerString = self.covertSecToMinAndHour(seconds: self.countSec)
            })
            
        } catch {
            print("Recording failed to start")
        }
        
        startUpdatingAudioLevels()
    }
    
    func stopRecording(){
        audioRecorder.stop()
        stopUpdatingAudioLevels()
        countSec = 0
        timerString = "0:00"
        showingAlert = true
        
        if let countTimer {
            countTimer.invalidate()
        }
    }
    
    func saveRecording(with title: String) {
        guard let tempURL = tempRecordingURL else { return }
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let newFileName = title.isEmpty ? Date().toString(dateFormat: "yyyy.MM.dd '일기'") : title
        var newFileURL = path.appendingPathComponent("\(newFileName).m4a")
        
        // 파일 이름 중복 처리
        var counter = 1
        while FileManager.default.fileExists(atPath: newFileURL.path) {
            let duplicatedFileName = "\(newFileName) (\(counter))"
            newFileURL = path.appendingPathComponent("\(duplicatedFileName).m4a")
            counter += 1
        }
        
        do {
            try FileManager.default.moveItem(at: tempURL, to: newFileURL)
            // 업데이트 된 레코딩 목록 등 후속 처리
        } catch {
            print("Error saving recording: \(error)")
        }
    }
    
    func toggleRecording() {
        if isRecording {
            isRecording = false
            stopRecording()
        } else {
            isRecording = true
            startRecording()
        }
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

              audioLevels = audioLevels.enumerated().map { index, previousLevel in
                  let randomVariance = CGFloat.random(in: 0.5...1.5)  // 무작위 변형 범위 확장
                  let targetLevel = baseLevel * randomVariance
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
        
        
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil)
            for i in directoryContents {
                let createdAtDate = getFileDate(for: i)
                let createdAtString = createdAtDate.toString(dateFormat: "yyyy.MM.dd")
                var day: Week = .mon
                
                switch createdAtDate.dayString() {
                case "Mon":
                    day = .mon
                case "Tue":
                    day = .tue
                case "Wed":
                    day = .wed
                case "Thu":
                    day = .thr
                case "Fri":
                    day = .fri
                case "Sat":
                    day = .sat
                case "Sun":
                    day = .sun
                default:
                    break
                }
                
                recordingsList.append(Recording(fileURL: i,createdAtDate: createdAtDate, createdAtString: createdAtString, isPlaying: false, day: day))
            }
        } catch {
            print("Error loading recordings: \(error)")

        }
        
        recordingsList.sort(by: { $0.createdAtDate.compare($1.createdAtDate) == .orderedDescending})
        
    }
    
    func startPlaying(url : URL) {
        
        playingURL = url
        
        let playSession = AVAudioSession.sharedInstance()
        
        do {
            try playSession.setCategory(.playback, mode: .default)
            try playSession.setActive(true)
            try playSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        } catch {
            print("Playing failed in Device \(error)")
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
            print("Playing Failed \(error)")
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
    
 
    func deleteRecording(offsets : IndexSet) {
        
        for index in offsets {
            let recordingURL = recordingsList[index].fileURL
            if recordingsList[index].isPlaying == true{
                stopPlaying(url: recordingsList[index].fileURL)
            }
            do {
                // 파일 시스템에서 파일 삭제
                try FileManager.default.removeItem(at: recordingURL)
            } catch {
                print("Can't delete with \(error)")
            }
        }
       
        // 녹음 목록에서 해당 인덱스 삭제
        recordingsList.remove(atOffsets: offsets)
    }
    
    
    func getFileDate(for file: URL) -> Date {
        if let attributes = try? FileManager.default.attributesOfItem(atPath: file.path) as [FileAttributeKey: Any],
            let creationDate = attributes[FileAttributeKey.creationDate] as? Date {
            return creationDate
        } else {
            return Date()
        }
    }
    
    func fetchRecordingWithDate(date: Date) -> Recording? {
        
        let calendar = Calendar.current
        var lastRecordingsByDay: [Date: Recording] = [:]
        
        for recording in recordingsList {
            if calendar.isDate(recording.createdAtDate, inSameDayAs: date) {
                if let lastRecording = lastRecordingsByDay[date], lastRecording.createdAtDate < recording.createdAtDate {
                    lastRecordingsByDay[date] = recording
                } else if lastRecordingsByDay[date] == nil {
                    lastRecordingsByDay[date] = recording
                }
            }
        }
        
        if let latestRecording = lastRecordingsByDay[date] {
            return latestRecording
        }else {
            return nil
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
