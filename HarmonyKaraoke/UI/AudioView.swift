//
//  AudioView.swift
//  HarmonyKaraoke
//
//  Created by 나현흠 on 6/3/25.
//

import SwiftUI
import AVKit

struct AudioPlayerView: View {
    
    @State var audioPlayer: AVAudioPlayer!
    @State var progress:CGFloat = 0.0
    @State private var playing: Bool = false
    @State var duration: Double = 0.0
    @State var formattedDurtaion: String = "20:00"
    @State var formattedProgress: String = "00:00"
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack{
                Text(formattedProgress).font(.caption.monospacedDigit())
                
                GeometryReader{ gr in
                    Capsule()
                        .stroke(Color.blue, lineWidth: 2)
                        .background(
                            Capsule()
                                .foregroundColor(Color.blue)
                                .frame(width: gr.size.width * progress, height: 8), alignment: .leading)
                }.frame( height: 8)
                
                Text(formattedDurtaion).font(.caption.monospacedDigit())
            }
            
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    let decrease = self.audioPlayer.currentTime - 15
                    if decrease < 0.0 {
                        self.audioPlayer.currentTime = 0.0
                    } else {
                        self.audioPlayer.currentTime -= 15
                    }
                    
                }){
                    Image(systemName: "gobackward.15")
                        .font(.title)
                        .imageScale(.medium)
                }
                Spacer()
                Button(action: {
                    if audioPlayer.isPlaying {
                        playing = false
                        self.audioPlayer.pause()
                    }else if !audioPlayer.isPlaying{
                        playing = true
                        self.audioPlayer.play()
                    }
                    
                }){
                    Image(systemName: playing ? "pause.circle.fill" : "play.circle.fill")
                        .font(.title)
                        .imageScale(.large)
                }
                
                Spacer()
                Button(action: {
                    let increase = self.audioPlayer.currentTime + 15
                    if increase < self.audioPlayer.duration {
                        self.audioPlayer.currentTime = increase
                    } else {
                        self.audioPlayer.currentTime = duration
                    }
                    
                }){
                    Image(systemName: "goforward.15")
                        .font(.title)
                        .imageScale(.medium)
                }
                Spacer()
            }
            Spacer()
        }.padding()
            .onAppear(){
                initialiseAudioPlayer()
            }
        
    }
    
    func initialiseAudioPlayer(){
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = [.pad]
        
        let path = Bundle.main.path(forResource: "내여자내남자(음원)", ofType: "mp3")!
        self.audioPlayer = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
        self.audioPlayer.prepareToPlay()
        
        formattedDurtaion = formatter.string(from: TimeInterval(self.audioPlayer.duration))!
        
        duration = self.audioPlayer.duration
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if !audioPlayer.isPlaying{
                playing = false
            }
            
            progress = CGFloat(audioPlayer.currentTime / audioPlayer.duration)
            
            formattedProgress = formatter.string(from: TimeInterval(self.audioPlayer.currentTime))!
        }
    }
}



struct AudioPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        AudioPlayerView()
            .previewLayout(
                PreviewLayout.fixed(width: 400, height: 300))
            .previewDisplayName("Default preview")
        AudioPlayerView()
            .previewLayout(
                PreviewLayout.fixed(width: 400, height: 300))
            .previewDisplayName("Default preview2")
            .environment(\.sizeCategory, .accessibilityExtraLarge)
    }
}
