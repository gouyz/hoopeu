//
//  RecorderManager.swift
//  SwiftRecorder
//
//  Created by iOS on 2018/9/25.
//  Copyright © 2018 AidaHe. All rights reserved.
//

import UIKit
import AVFoundation

enum RecordType :String {
    case Caf = "caf"
    case Wav = "wav"
}

class RecordManager: NSObject {
    
    var recorder: AVAudioRecorder?
    var player: AVAudioPlayer?
    var recordName:String?
    var timer: Timer!
    var recordSeconds: NSInteger = 0
    
    func beginRcord(recordType:RecordType){
        recordSeconds = 0
        let session = AVAudioSession.sharedInstance()
        //设置session类型
        do {
            try session.setCategory(AVAudioSession.Category.playAndRecord,options: .defaultToSpeaker)
        } catch let err{
            print("设置类型失败:\(err.localizedDescription)")
        }
        //设置session动作
        do {
            try session.setActive(true)
        } catch let err {
            print("初始化动作失败:\(err.localizedDescription)")
        }
       
        let recordSetting: [String: Any] = [
            AVSampleRateKey: NSNumber(value: 8000),//采样率
//            AVEncoderBitRateKey:NSNumber(value: 16000),
            AVFormatIDKey: NSNumber(value: kAudioFormatLinearPCM),//音频格式
            AVNumberOfChannelsKey: NSNumber(value: 1),//通道数
//            AVLinearPCMBitDepthKey:NSNumber(value: 16),
            AVEncoderAudioQualityKey: NSNumber(value: AVAudioQuality.max.rawValue)//录音质量
        ];
        //开始录音
        do {
            let now = Date()
            let timeInterval:TimeInterval = now.timeIntervalSince1970
            let timeStamp = Int(timeInterval)
            recordName = now.dateToStringWithFormat(format: "yyyyMMdd") + "\(timeStamp)"
            let fileType = (recordType == RecordType.Caf) ? "caf" : "wav"
//            let filePath = NSHomeDirectory() + "/Documents/voiceMsg/\(recordName!).\(fileType)"
//            let filePath = documentsDirectoryURL(name: "/voiceMsg/\(recordName!).\(fileType)")
            let url = documentsDirectoryURL(name: "\(recordName!).\(fileType)")//URL(fileURLWithPath: filePath)
            recorder = try AVAudioRecorder(url: url, settings: recordSetting)
            recorder!.prepareToRecord()
            recorder!.record()
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(onClickTimer), userInfo: nil, repeats: true)
            print("开始录音----")
        } catch let err {
            if timer != nil {
                timer.invalidate()
            }
            self.recordSeconds = 0
            print("录音失败:\(err.localizedDescription)")
        }
    }
    
    //结束录音
    func stopRecord() {
        if timer != nil {
            timer.invalidate()
        }
        if let recorder = self.recorder {
            recorder.stop()
            print("停止录音----")
            self.recorder = nil
        }else {
            print("停止失败")
        }
    }
    
    @objc func onClickTimer(){
        self.recordSeconds += 1
        print("正在录音：\(self.recordSeconds)s")
    }
    
    //播放
    func play(recordType:RecordType) {
        do {
            let fileType = (recordType == RecordType.Caf) ? "caf" : "wav"
            let url = documentsDirectoryURL(name: "\(recordName!).\(fileType)")
//            let filePath = NSHomeDirectory() + "/Documents/voiceMsg/\(recordName!).\(fileType)"
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            print("播放录音长度：\(player!.duration)")
            player!.play()
        } catch let err {
            print("播放失败:\(err.localizedDescription)")
        }
    }
    
    func convertCafToMp3(){
        let audioPath = NSHomeDirectory() + "/Documents/\(recordName!).caf"
        let mp3Path = NSHomeDirectory() + "/Documents/\(recordName!).mp3"
        ConvertMp3().audioPCMtoMP3(audioPath, mp3File: mp3Path)
        print("caf源文件:\(audioPath)")
        print("mp3文件:\(mp3Path)")
    }
    
    func convertWavToAmr(){
        let wavPath = documentsDirectoryURL(name: "\(recordName!).wav")//NSHomeDirectory() + "/Documents/voiceMsg/\(recordName!).wav"
        do {
            let wavData = try Data(contentsOf: wavPath)
            let amrData = convert8khzWaveToAmr(waveData: wavData)//convert16khzWaveToAmr(waveData: wavData)
            let amrPath = documentsDirectoryURL(name: "\(recordName!).amr")//NSHomeDirectory() + "/Documents/voiceMsg/\(recordName!).amr"
            try amrData?.write(to: amrPath)
            print("wav源文件：\(wavPath)")
            print("amr文件：\(amrPath)")
        }catch let err {
            print("转amr文件异常：\(err.localizedDescription)")
        }
        
    }
    
    func convertAmrToWav(){
//        let amrPath = NSHomeDirectory() + "/Documents/voiceMsg/\(recordName!).amr"
        let amrPath = documentsDirectoryURL(name: "\(recordName!).amr")
        do {
            let amrData = try Data(contentsOf: amrPath)
            let wavData = convertAmrNBToWave(data: amrData)//convertAmrWBToWave(data: amrData)
//            let wavPath = NSHomeDirectory() + "/Documents/voiceMsg/\(recordName!)_fromAmr.wav"
            let wavPath = documentsDirectoryURL(name: "\(recordName!)_fromAmr.wav")
            try wavData?.write(to: wavPath)
            print("amr源文件：\(amrPath)")
            print("wav文件：\(wavPath)")
        }catch let err {
            print("转wav文件异常：\(err.localizedDescription)")
        }
    }
    
    func playWav(){
        do {
            let filePath = documentsDirectoryURL(name: "\(recordName!)_fromAmr.wav")//NSHomeDirectory() + "/Documents/voiceMsg/\(recordName!)_fromAmr.wav"
            player = try AVAudioPlayer(contentsOf: filePath)
            print("播放录音长度：\(player!.duration)")
            player?.prepareToPlay()
            player!.play()
        } catch let err {
            print("播放失败:\(err.localizedDescription)")
        }
    }
    
    func documentsDirectoryURL(name: String) -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(name)
    }
}
