//
//  KaraokeLyricView.swift
//  HarmonyKaraoke
//
//  Created by 나현흠 on 6/3/25.
//

import SwiftUI

struct KaraokeLyricView: View {
    // MARK: LyricProvider에서 json 파일 입력해서 가져오기
    let lyricProvider = LyricProvider(jsonFileName: "내 여자 내 남자 가삭")

    // MARK: - State
    @State private var currentLineIndex: Int = 0
    @State private var currentLine: LyricLine = LyricLine(text: "내 여자 내 남자 - 배금성", timings: [0.00, 1.03, 1.3, 1.43, 1.65, 2.27, 2.57, 2.85, 3.07, 4.1, 4.4, 4.7, 5.0, 5.3, 5.7, 6.0])
    @State private var currentCharacterIndex: Int = 0
    @State private var characterProgress: CGFloat = 0.0
    @State private var currentCharDuration: Double = 0.0
    @State private var startTime: Date = Date()
    @State private var countdown: Int? = nil

    let timer = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect() // ~60fps

    // MARK: - Derived property for current lyric line
    var lyricsWithDuration: [(String, Double)] {
        currentLine.characterDurations
    }

    var body: some View {
        let fullText = lyricsWithDuration.map { $0.0 }.joined()
        let highlightedText = lyricsWithDuration.prefix(currentCharacterIndex).map { $0.0 }.joined()
        let currentChar = currentCharacterIndex < lyricsWithDuration.count ? lyricsWithDuration[currentCharacterIndex].0 : ""

        VStack {
            if let count = countdown {
                Text(["하나", "둘", "셋", "넷"][count])
                    .font(.largeTitle)
                    .bold()
                    .transition(.opacity)
            }
            Text("\(currentLineIndex)")

            ZStack(alignment: .leading) {
                
                Text(fullText)
                    .foregroundColor(.gray)
                    .bold()

                HStack(spacing: 0) {
                    
                    //이미 파란색으로 채워진 텍스트들
                    Text(highlightedText)
                        .foregroundColor(.blue)
                        .bold()

                    //두개로 label을 나눠서 마스크 & 텍스트를 두개로 해버리는게 나을까?
                    //아니면 mask가 Text 위치를 따라갈 수 있는 방법이 있을까?
                    if !currentChar.isEmpty {
                        Text(currentChar)
                            .foregroundColor(.blue)
                            .bold()
                            .mask(
                                GeometryReader { geo in
                                    Rectangle()
                                        .frame(width: geo.size.width * characterProgress)
                                }
                            )
                    }
                }
            }
            .font(.title)
            .padding()
            ZStack(alignment: .leading) {
                
                Text(fullText)
                    .foregroundColor(.gray)
                    .bold()

                HStack(spacing: 0) {
                    
                    //이미 파란색으로 채워진 텍스트들
                    Text(highlightedText)
                        .foregroundColor(.blue)
                        .bold()

                    //두개로 label을 나눠서 마스크 & 텍스트를 두개로 해버리는게 나을까?
                    //아니면 mask가 Text 위치를 따라갈 수 있는 방법이 있을까?
                    if !currentChar.isEmpty {
                        Text(currentChar)
                            .foregroundColor(.blue)
                            .bold()
                            .mask(
                                GeometryReader { geo in
                                    Rectangle()
                                        .frame(width: geo.size.width * characterProgress)
                                }
                            )
                    }
                }
            }
            .font(.title)
            .padding()
            

            HStack{
                
                // "이전" button to go to previous lyric line
                Button("이전") {
                    let lines = lyricProvider.lyricLines
                    if currentLineIndex > 0 {
                        currentLineIndex -= 1
                        currentLine = lines[currentLineIndex]
                        currentCharacterIndex = 0
                        characterProgress = 0
                        countdown = 0
                        startCountdown()
                    }
                }
                .padding()
                Button("다시") {
                    let lines = lyricProvider.lyricLines
                    if currentLineIndex >= 0 {
                        currentLine = lines[currentLineIndex]
                        currentCharacterIndex = 0
                        characterProgress = 0
                        countdown = 0
                        startCountdown()
                    }
                }
                .padding()
                Button("다음") {
                    let lines = lyricProvider.lyricLines
                    if currentLineIndex + 1 < lines.count {
                        currentLineIndex += 1
                        currentLine = lines[currentLineIndex]
                        currentCharacterIndex = 0
                        characterProgress = 0
                        countdown = 0
                        startCountdown()
                    }
                }
                .padding()
            }
        }
        
        //가사 줄 배열 불러오고, 첫 글자 재생 타이밍 설정
        .onAppear {
            let lines = lyricProvider.lyricLines
//            print("🔥 Loaded \(lines.count) lyric lines from LyricProvider")
//            for line in lines {
//                print("🎵 \(line.text) - timings: \(line.timings)")
//            }
            if !lines.isEmpty {
                currentLine = lines[currentLineIndex]
                currentCharDuration = lyricsWithDuration.first?.1 ?? 0.0
                startTime = Date()
            }
        }
        
        //1/60초 마다 (개빨리) 실행됨. 카운트 다운 중이면 안하고 characterProgress = 지나간 시간 / 글자 총 지속시간 형태로 진행상태 확인하며 characterProgress가 1.0 이상이면 다음 글자로 이동한다.
        .onReceive(timer) { _ in
            guard countdown == nil else { return }
            guard currentCharacterIndex < lyricsWithDuration.count else { return }

            let elapsed = Date().timeIntervalSince(startTime)
            let duration = lyricsWithDuration[currentCharacterIndex].1
            characterProgress = min(1.0, elapsed / duration)

            if characterProgress >= 1.0 {
                currentCharacterIndex += 1
                characterProgress = 0.0
                if currentCharacterIndex < lyricsWithDuration.count {
                    currentCharDuration = lyricsWithDuration[currentCharacterIndex].1
                    startTime = Date()
                }
            }
        }
    }

    // 이건 그냥 하나 둘 셋 넷 카운터 딱히 필요는 없슴
    private func startCountdown() {
        Timer.scheduledTimer(withTimeInterval: 0.37, repeats: true) { timer in
            countdown! += 1
            if countdown! >= 4 {
                countdown = nil
                currentCharDuration = lyricsWithDuration.first?.1 ?? 0.0
                startTime = Date()
                timer.invalidate()
            }
        }
    }
}

#Preview{
    KaraokeLyricView()
}
