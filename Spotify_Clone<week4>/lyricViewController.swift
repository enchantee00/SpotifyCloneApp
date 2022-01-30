//
//  lyricViewController.swift
//  Spotify_Clone<week4>
//
//  Created by 정지윤 on 2021/12/18.
//

import Foundation
import UIKit
import AVFoundation

class lyricViewController: UIViewController{
    
    
    var player : AVAudioPlayer!
    var timer : Timer!
    var session: AVAudioSession!
    
    @IBOutlet weak var entireLyric: UILabel!
    
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var firstTime: UILabel!
    @IBOutlet weak var lastTime: UILabel!
    @IBOutlet weak var lyricPauseButton: UIButton!
    
    
    
    @IBAction func closeLyric(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        invalidateTimer()
    }
    
    @IBAction func touchUpPause(_ sender: UIButton) {
    
        if !player.isPlaying{
            self.player?.play()
            self.lyricPauseButton.setImage(UIImage(systemName: "pause.circle.fill"), for: .normal)
        } else{
            self.player?.pause()
            self.lyricPauseButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
        }
    }
    
    @IBAction func sliderValueControl(_ sender: UISlider) {
        self.updateTimeLabelText(time: TimeInterval(sender.value), duration: self.player.duration)
        if sender.isTracking{return}
        self.player.currentTime = TimeInterval(sender.value);
    }
    
    
//    func configureAudioSession() {
//        //Audio Session 설정
//        let audioSession = AVAudioSession.sharedInstance()
//        do {
//            try audioSession.setCategory(.playback, mode: .default, options: [])
//
//        } catch let error as NSError {
//            print("audioSession 설정 오류 : \(error.localizedDescription)")
//        }
//    }
    
    
    
    //레이블 업데이트 -> main Thread
    func updateTimeLabelText(time:TimeInterval, duration: TimeInterval){
        let minute : Int = Int(time/60);
        let second : Int = Int(time.truncatingRemainder(dividingBy: 60));
        let leftMinute : Int = Int((duration-time)/60)
        let leftSecond : Int = Int((duration-time).truncatingRemainder(dividingBy: 60));
        
        let timeText : String = String(format : "%01ld:%02ld", minute, second);
        let leftTimeText : String = String(format : "%01ld:%02ld", leftMinute, leftSecond)
        
        self.firstTime.text = timeText;
        self.lastTime.text = "-\(leftTimeText)"
        
    }
    
    // 타이머를 만들고 수행해줄 메소드
    func makeAndFireTimer(){

        self.timer = Timer.scheduledTimer(withTimeInterval : 0.01, repeats: true, block : { [unowned self] (timer : Timer) in
            
            DispatchQueue.main.async {
                if self.timeSlider.isTracking { return };
                self.updateTimeLabelText(time: self.player.currentTime, duration: self.player.duration);
                self.timeSlider.value = Float(self.player.currentTime);
            }

        })
        self.timer.fire();
    }
    
    
    // 플레이어 재생 관련 에러처리.
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        guard let error: Error = error else{
            print("플레이어 오류 발생");
            return }
        let message : String
        message = "플레이어 오류 발생 \(error.localizedDescription)";
        let alert : UIAlertController = UIAlertController(title:"알림", message : message, preferredStyle :UIAlertController.Style.alert);
        let okAction : UIAlertAction = UIAlertAction(title : "확인", style : UIAlertAction.Style.default) { ( action:UIAlertAction) -> Void in
            self.dismiss(animated: true, completion:nil)
        }
        alert.addAction(okAction)
        self.present(alert, animated:true, completion:nil)
        
    }
    
    
    // 음악 재생이 끝나면
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.timeSlider.value = 0;
        self.updateTimeLabelText(time: 0, duration: self.player.duration)
        self.invalidateTimer()
        self.lyricPauseButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
    }
    
    
    // 타이머 해제
    func invalidateTimer(){
        self.timer.invalidate();
        self.timer = nil;
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.timeSlider.maximumValue = Float(self.player.duration);
        self.timeSlider.minimumValue = 0;
        
//        configureAudioSession()
        self.makeAndFireTimer()
    }
    
//    func viewWillAppear() {
//
//
//    }
}
