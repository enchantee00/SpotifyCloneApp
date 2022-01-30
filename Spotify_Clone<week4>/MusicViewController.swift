//
//  ViewController.swift
//  Spotify_Clone<week4>
//
//  Created by 정지윤 on 2021/12/17.
//

import UIKit
import Gifu
import AVFoundation

class MusicViewController: UIViewController, AVAudioPlayerDelegate, ObservableObject {
    
    var player : AVAudioPlayer!
    var timer : Timer!
    var session: AVAudioSession!

//    let playBtnImg = UIImage(named: "play.circle.fill")!;
//    let pauseBtnImg = UIImage(named: "pause.circle.fill")!;

    var initialSong : Bool!
    
    
    @IBOutlet weak var gifAnimationView: GIFImageView!
    
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var firstTime: UILabel!
    @IBOutlet weak var lastTime: UILabel!
    
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var lyricView: UIView!
    
    
    //뷰 클릭했을 때
    @objc func lyricViewTapped(sender: UITapGestureRecognizer){
        let lvc = storyboard?.instantiateViewController(withIdentifier: "lyricView") as! lyricViewController
        
        lvc.player = self.player
        lvc.timer = self.timer
        
        
        lvc.modalTransitionStyle = .coverVertical
        lvc.modalPresentationStyle = .fullScreen
        
        self.present(lvc, animated: true, completion: nil)
        
    }
    
    
    // 슬라이더 이용한 오디오 제어
    @IBAction func sliderValueControl(_ sender: UISlider) {
        self.updateTimeLabelText(time: TimeInterval(sender.value), duration: self.player.duration)
        if sender.isTracking{return}
        self.player.currentTime = TimeInterval(sender.value);
    }
    
    //버튼 눌렀을 때, 재생 & 멈춤
    @IBAction func touchUpPause(_ sender: UIButton) {
        
    
        if !player.isPlaying{
            self.player?.play()
            sender.setImage(UIImage(systemName: "pause.circle.fill"), for: .normal)
        } else{
            self.player?.pause()
            sender.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
        }
        
//        if sender.isSelected{
//            self.makeAndFireTimer()
//
//        } else{
//            self.invalidateTimer()
//        }
        
    }
    
    //좋아요 버튼 눌렀을 때
    @IBAction func selectedLike(_ sender: Any) {
    }
    
    //반복재생 버튼 눌렀을 때
    @IBAction func selectedRepeat(_ sender: Any) {
        
        self.player.numberOfLoops = -1
    }
    
    
    //플레이어 초기화
    func initializePlayer(){
        
        //Audio Session 설정
//        let audioSession = AVAudioSession.sharedInstance()
//        do {
//            try audioSession.setCategory(.playback, mode: .default, options: [])
//
//        } catch let error as NSError {
//            print("audioSession 설정 오류 : \(error.localizedDescription)")
//        }
        

        //음악 파일 재생 -> 따로 내장된 다른 Thread에서 진행함
        guard let soundAsset : NSDataAsset = NSDataAsset(name : "MyMister") else {
            print("음원없음");
            return;
        }
        
        //백그라운드 음악 재생
        

        
        do {
            try self.player = AVAudioPlayer(data : soundAsset.data);
            self.player.delegate = self;
            print("노래 시작")
            self.player?.play()
            
        } catch let error {
            print("초기화 실패");
            print("에러 남 : \(error)");
        }
        
        self.timeSlider.maximumValue = Float(self.player.duration);
        self.timeSlider.minimumValue = 0;
        self.makeAndFireTimer()
        
    }

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
        self.pauseButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
        self.invalidateTimer()
        self.initialSong = true
    }
    
    
    // 타이머 해제
    func invalidateTimer(){
        self.timer.invalidate();
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers, .allowAirPlay])
            print("Playback OK")
            try AVAudioSession.sharedInstance().setActive(true)
            print("Session is Active")
        } catch {
            print(error)
        }
        
        self.initializePlayer();
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(lyricViewTapped))
        self.lyricView.addGestureRecognizer(tapGestureRecognizer)
        
        
//        pauseButton.setBackgroundImage(pauseBtnImg, for: .normal);
//        pauseButton.setBackgroundImage(playBtnImg, for: .highlighted);
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        playGifViedeo()
    }
    
    
    
    private func playGifViedeo() {
        DispatchQueue.main.async { [weak self] in
            self?.gifAnimationView.animate(withGIFNamed: "MyMisterBackground", animationBlock: { [weak self] in
                self?.gifAnimationView.animate(withGIFNamed: "MyMisterBackground2")
            })
        }
    }
    
    
    
    
    
}







