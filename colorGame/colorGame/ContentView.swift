//
//  ContentView.swift
//  colorGame
//
//  Created by Palacios, Litzy N on 4/23/25.
//

import SwiftUI

// MARK: - Models

struct HighScoreEntry: Codable, Identifiable {
    var id: UUID
    let score: Int
    let playerName: String
    let date: Date
}

enum ColorTheme: String, CaseIterable, Identifiable {
    case classic = "Classic"
    case pastel = "Pastel"
    case neon = "Neon"
    var id: String { self.rawValue }
}

struct NamedColor: Identifiable, Hashable {
    var id = UUID()
    let name: String
    let color: Color
}

// MARK: - ContentView

struct ContentView: View {
    // MARK: - Color Sets
    let classicColors: [NamedColor] = [
        NamedColor(name: "Red", color: .red),
        NamedColor(name: "Green", color: .green),
        NamedColor(name: "Blue", color: .blue),
        NamedColor(name: "Yellow", color: .yellow),
        NamedColor(name: "Purple", color: .purple),
        NamedColor(name: "Orange", color: .orange)
    ]

    let pastelColors: [NamedColor] = [
        NamedColor(name: "Pink", color: Color(red: 1.0, green: 0.8, blue: 0.8)),
        NamedColor(name: "Mint", color: Color(red: 0.8, green: 1.0, blue: 0.8)),
        NamedColor(name: "Baby Blue", color: Color(red: 0.8, green: 0.9, blue: 1.0)),
        NamedColor(name: "Pastel Yellow", color: Color(red: 1.0, green: 1.0, blue: 0.8)),
        NamedColor(name: "Lavender", color: Color(red: 0.9, green: 0.8, blue: 1.0)),
        NamedColor(name: "Peach", color: Color(red: 1.0, green: 0.9, blue: 0.8))
    ]

    let neonColors: [NamedColor] = [
        NamedColor(name: "Neon Green", color: Color(red: 0.1, green: 1.0, blue: 0.1)),
        NamedColor(name: "Hot Pink", color: Color(red: 1.0, green: 0.2, blue: 0.6)),
        NamedColor(name: "Electric Blue", color: Color(red: 0.2, green: 0.8, blue: 1.0)),
        NamedColor(name: "Neon Yellow", color: Color(red: 1.0, green: 1.0, blue: 0.2)),
        NamedColor(name: "Lime", color: Color(red: 0.6, green: 1.0, blue: 0.2)),
        NamedColor(name: "Neon Orange", color: Color(red: 1.0, green: 0.5, blue: 0.0))
    ]

    // MARK: - State
    @State private var selectedTheme: ColorTheme = .classic
    @State private var currentNamedColor: NamedColor = NamedColor(name: "Red", color: .red)
    @State private var score = 0
    @State private var animateScore = false
    @State private var showRedX = false
    @State private var timeLeft = 3.0
    @State private var currentTimeLimit = 3.0
    @State private var timer: Timer?
    @State private var showGameOver = false
    @State private var roundHasStarted = false
    @State private var scoreEndedAtZero = false
    @State private var playerName = ""
    @State private var hasStarted = false
    @State private var homeButtonTapped = false
    @State private var highScores: [HighScoreEntry] = []
    @State private var showLeaderboardSheet = false
    @State private var neonUnlocked = false
    @State private var showUnlockMessage = false
    @State private var showUnlockConfetti = false
    @State private var animatePicker = false
    @State private var isNewHighScore = false
    @State private var animateTitle = false
    @State private var dropIn = false
    @State private var shakeStartButton = false



    let minTimeLimit = 1.0
    let timeDecreasePerRound = 0.2
    let maxHighScores = 5

    var currentColorSet: [NamedColor] {
        switch selectedTheme {
        case .classic: return classicColors
        case .pastel: return pastelColors
        case .neon: return neonColors
        }
    }

    var textColor: Color {
        selectedTheme == .classic ? .white : .black
    }
    
    var glowColor: Color {
        switch selectedTheme {
        case .classic: return .purple
        case .pastel: return .mint
        case .neon: return .yellow
        }
    }


    var availableThemes: [ColorTheme] {
        neonUnlocked ? ColorTheme.allCases : ColorTheme.allCases.filter { $0 != .neon }
    }

    var body: some View {
        ZStack {
            if !hasStarted {
                LinearGradient(colors: [.purple, .blue], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                VStack(spacing: 30) {
                    ZStack {
                        // Glowing background text
                        Text("🎨 Color Match Dash 🎮")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundColor(glowColor) // 🔥 use theme-based glow
                            .blur(radius: 4)
                            .opacity(0.6)
                            .scaleEffect(animateTitle ? 1.05 : 1.0)
                            .offset(y: dropIn ? (animateTitle ? -5 : 5) : -300)


                        // Foreground text
                        Text("🎨 Color Match Dash 🎮")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .scaleEffect(animateTitle ? 1.05 : 1.0)
                            .offset(y: dropIn ? (animateTitle ? -5 : 5) : -300)
                    }
                    .opacity(dropIn ? 1 : 0)
                    .animation(.interpolatingSpring(stiffness: 120, damping: 10), value: dropIn)
                    .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: animateTitle)
                    .onAppear {
                        dropIn = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            animateTitle = true
                        }
                    }


                    VStack(spacing: 20) {
                        Text("What’s your name?")
                            .font(.headline)
                            .foregroundColor(.white)

                        TextField("First name", text: $playerName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal, 40)
                            .onChange(of: playerName) { oldValue, newValue in
                                if newValue.count == 1 {
                                    withAnimation {
                                        shakeStartButton = true
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        shakeStartButton = false
                                    }
                                }
                            }



                        Text("Choose a Color Theme:")
                            .foregroundColor(.white)

                        Picker("Color Theme", selection: $selectedTheme) {
                            ForEach(availableThemes) { theme in
                                Text(theme.rawValue).tag(theme)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                        .scaleEffect(animatePicker ? 1.1 : 1.0)
                        .animation(.easeOut(duration: 0.3), value: animatePicker)

                        if !neonUnlocked {
                            Text("🔒 Score 60+ to unlock Neon!")
                                .font(.caption)
                                .foregroundColor(.white)
                        }

                        Button("Start Game 🚀") {
                            if !playerName.isEmpty {
                                hasStarted = true
                                startRound()
                            }
                        }
                        .font(.title2)
                        .padding()
                        .frame(width: 200)
                        .background(playerName.isEmpty ? Color.gray : Color.yellow)
                        .foregroundColor(.black)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                        .disabled(playerName.isEmpty)
                        .offset(x: shakeStartButton ? -10 : 0)
                        .animation(.easeInOut(duration: 0.1).repeatCount(6, autoreverses: true), value: shakeStartButton)



                        Button("🏆 High Scores") {
                            showLeaderboardSheet.toggle()
                        }
                        .font(.body)
                        .padding(.vertical, 8)
                        .frame(width: 160)
                        .background(Color.white)
                        .foregroundColor(.purple)
                        .cornerRadius(10)
                        .shadow(radius: 3)

                    }
                }
                .onAppear {
                    loadHighScores()
                    neonUnlocked = UserDefaults.standard.bool(forKey: "NeonUnlocked")
                }
                .sheet(isPresented: $showLeaderboardSheet) {
                    LeaderboardView(highScores: highScores) {
                        showLeaderboardSheet = false
                    }
                }
            } else {
                currentNamedColor.color.ignoresSafeArea()

                VStack {
                    HStack {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                homeButtonTapped = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                homeButtonTapped = false
                                goHome()
                            }
                        }) {
                            Image(systemName: "house.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black.opacity(0.3))
                                .clipShape(Circle())
                                .scaleEffect(homeButtonTapped ? 0.8 : 1.0)
                                .animation(.spring(), value: homeButtonTapped)
                        }
                        Spacer()
                    }
                    .padding([.top, .leading], 20)

                    Spacer()

                    VStack(spacing: 30) {
                        Text("Score: \(score)")
                            .font(.title)
                            .foregroundColor(textColor)

                        Text("Time Left: \(String(format: "%.1f", timeLeft))")
                            .font(.headline)
                            .foregroundColor(textColor)

                        LazyVGrid(columns: [GridItem(), GridItem()], spacing: 20) {
                            ForEach(currentColorSet) { namedColor in
                                Button(action: {
                                    handleTap(selectedColor: namedColor)
                                }) {
                                    Text(namedColor.name)
                                        .foregroundColor(textColor)
                                        .frame(width: 120, height: 50)
                                        .background(namedColor.color)
                                        .cornerRadius(12)
                                        .shadow(radius: 5)
                                }
                            }
                        }
                    }
                    .padding()

                    Spacer()
                }

                if showRedX {
                    Text("❌")
                        .font(.system(size: 100))
                        .foregroundColor(.red)
                        .transition(.scale.combined(with: .opacity))
                        .zIndex(1)
                }

                if showGameOver {
                    VStack(spacing: 20) {
                        
                        if isNewHighScore {
                            Text("🌟 New high score! Great job, \(playerName.capitalized)! 🌟")
                                .font(.headline)
                                .foregroundColor(.yellow)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        
                        Text("⏱ Game Over")
                            .font(.largeTitle)
                            .foregroundColor(.white)

                        if scoreEndedAtZero {
                            Text("Oops, you ran out of points, \(playerName.capitalized)! Try again?")
                                .font(.title2)
                                .foregroundColor(.white)
                        } else {
                            Text("Great try, \(playerName.capitalized)!")
                                .font(.title2)
                                .foregroundColor(.white)
                            Text("Final Score: \(score)")
                                .font(.title2)
                                .foregroundColor(.white)
                        }

                        Button("Play Again") {
                            resetGame()
                        }
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                    }
                    .padding(30) // Increased padding
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(30) // Slightly more rounded
                    .shadow(radius: 10)
                    .padding()
                }
            }

            // 🎉 Neon Unlock Message
            if showUnlockMessage {
                VStack {
                    Spacer()
                    Text("🔓 Neon Theme Unlocked!")
                        .font(.title2)
                        .padding()
                        .background(Color.white.opacity(0.95))
                        .foregroundColor(.purple)
                        .cornerRadius(14)
                        .shadow(radius: 10)
                        .transition(.scale.combined(with: .opacity))
                        .padding(.bottom, 100)
                }
                .animation(.easeOut(duration: 0.3), value: showUnlockMessage)
            }

            // 🎊 Confetti
            if showUnlockConfetti {
                ConfettiView()
                    .transition(.opacity)
                    .zIndex(2)
            }
        }
    }

    // MARK: - Game Logic & Unlocks

    func startRound() {
        currentNamedColor = currentColorSet.randomElement()!
        timeLeft = currentTimeLimit
        roundHasStarted = true

        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { t in
            timeLeft -= 0.1
            if timeLeft <= 0 {
                t.invalidate()
                showGameOver = true
                scoreEndedAtZero = false
                saveScoreIfHigh()
                checkAndUnlockNeon()
            }
        }
    }

    func handleTap(selectedColor: NamedColor) {
        withAnimation { animateScore = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { animateScore = false }

        if selectedColor.color.description == currentNamedColor.color.description {
            score += 1
            currentTimeLimit = max(currentTimeLimit - timeDecreasePerRound, minTimeLimit)
        } else {
            score -= 1
            showXPopup()
        }

        if score <= 0 && roundHasStarted {
            timer?.invalidate()
            showGameOver = true
            scoreEndedAtZero = true
            saveScoreIfHigh()
            checkAndUnlockNeon()
            return
        }

        startRound()
    }

    func checkAndUnlockNeon() {
        if score >= 60 && !neonUnlocked {
            neonUnlocked = true
            UserDefaults.standard.set(true, forKey: "NeonUnlocked")
            showUnlockMessage = true
            showUnlockConfetti = true
            animatePicker = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showUnlockMessage = false
                showUnlockConfetti = false
                animatePicker = false
            }
        }
    }

    func resetUnlocks() {
        UserDefaults.standard.removeObject(forKey: "NeonUnlocked")
        neonUnlocked = false
    }

    func showXPopup() {
        withAnimation { showRedX = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation { showRedX = false }
        }
    }

    func resetGame() {
        score = 0
        currentTimeLimit = 3.0
        showGameOver = false
        roundHasStarted = false
        scoreEndedAtZero = false
        startRound()
    }

    func goHome() {
        timer?.invalidate()
        score = 0
        currentTimeLimit = 3.0
        showGameOver = false
        roundHasStarted = false
        scoreEndedAtZero = false
        hasStarted = false
    }

    // MARK: - High Scores
    func saveScoreIfHigh() {
        guard score > 0 else { return }

        let previousHigh = UserDefaults.standard.integer(forKey: "HighestScore")
        isNewHighScore = score > previousHigh

        if isNewHighScore {
            UserDefaults.standard.set(score, forKey: "HighestScore")
        }

        var entries = loadSavedHighScores()
        let newEntry = HighScoreEntry(id: UUID(), score: score, playerName: playerName, date: Date())
        entries.append(newEntry)
        entries.sort { $0.score > $1.score }
        if entries.count > 5 {
            entries = Array(entries.prefix(5))
        }
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: "HighScoreEntries")
        }
        highScores = entries
    }

    func loadHighScores() {
        highScores = loadSavedHighScores()
    }

    func loadSavedHighScores() -> [HighScoreEntry] {
        guard let data = UserDefaults.standard.data(forKey: "HighScoreEntries"),
              let decoded = try? JSONDecoder().decode([HighScoreEntry].self, from: data)
        else { return [] }
        return decoded
    }
}

// MARK: - Confetti View

struct ConfettiView: View {
    let colors: [Color] = [.red, .yellow, .green, .blue, .purple, .orange]
    let count = 100

    var body: some View {
        ZStack {
            ForEach(0..<count, id: \.self) { i in
                Circle()
                    .fill(colors.randomElement() ?? .white)
                    .frame(width: CGFloat.random(in: 5...10), height: CGFloat.random(in: 5...10))
                    .position(x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                              y: CGFloat.random(in: 0...UIScreen.main.bounds.height))
                    .opacity(Double.random(in: 0.7...1.0))
                    .transition(.scale)
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - Leaderboard View

struct LeaderboardView: View {
    let highScores: [HighScoreEntry]
    var onClose: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("🏆")
                .font(.system(size: 80))
                .padding(.top)

            Text("Top 5 Scores")
                .font(.largeTitle)

            ForEach(highScores) { entry in
                VStack(spacing: 4) {
                    Text("\(entry.playerName): \(entry.score) points")
                        .font(.title2)
                    Text(dateFormatter.string(from: entry.date))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            Button("Close") {
                onClose()
            }
            .padding()
            .font(.headline)
            .background(Color.purple)
            .foregroundColor(.white)
            .cornerRadius(12)
            .padding(.bottom)
        }
        .padding()
    }
}

// MARK: - Date Formatter

let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()






#Preview {
    ContentView()
}
