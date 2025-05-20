import SwiftUI

struct Player: Identifiable {
    let id = UUID()
    let name: String
    var rating: Int = 1000
}

struct ContentView: View {
    @State private var nameInput = ""
    @State private var players: [Player] = []
    @State private var pairs: [(Player, Player)] = []
    @State private var currentPairIndex = 0
    @State private var round = 1
    @State private var showLeaderboard = false
    @State private var totalRounds = 3

    var body: some View {
        VStack {
            if players.isEmpty {
                TextField("Enter names separated by commas", text: $nameInput)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button("Start") {
                    let names = nameInput
                        .split(separator: ",")
                        .map { $0.trimmingCharacters(in: .whitespaces) }
                        .filter { !$0.isEmpty }
                    players = names.map { Player(name: $0) }
                    generatePairs()
                }
                .padding()
            } else if showLeaderboard {
                Text("🏆 Final Elo Leaderboard")
                    .font(.title)
                    .padding()

                List {
                    ForEach(players.sorted(by: { $0.rating > $1.rating })) { player in
                        HStack {
                            Text(player.name)
                            Spacer()
                            Text("\(player.rating)")
                        }
                    }
                }
                // Restart and 3 more rounds buttons
                                HStack {
                                    Button("Restart") {
                                        resetGame()
                                    }
                                    .padding()
                                    .background(Color.blue.opacity(0.7))
                                    .foregroundColor(.white)
                                    .cornerRadius(12)

                                    Button("Play 3 More Rounds") {
                                        totalRounds = totalRounds + 3
                                        resetGame()
                                        generatePairs()
                                    }
                                    .padding()
                                    .background(Color.green.opacity(0.7))
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                }
                                .padding()
            
            } else {
                if currentPairIndex < pairs.count {
                    let p1 = pairs[currentPairIndex].0
                    let p2 = pairs[currentPairIndex].1

                    Text("Round \(round)")
                        .font(.headline)
                        .padding()

                    HStack {
                        Button(action: {
                            processMatch(winner: p1, loser: p2)
                        }) {
                            Text(p1.name)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.opacity(0.7))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }

                        Button(action: {
                            processMatch(winner: p2, loser: p1)
                        }) {
                            Text(p2.name)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green.opacity(0.7))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                    .padding()
                } else {
                    // End of round
                    Color.clear
                            .onAppear {
                                if round < totalRounds {
                                    round += 1
                                    currentPairIndex = 0
                                    generatePairs()
                                } else {
                                    showLeaderboard = true
                                }
                            }
                }
            }
        }
        .padding()
    }
    // MARK: - Elo Logic
    func generatePairs() {
        players.shuffle()
        pairs = []
        var i = 0
        while i + 1 < players.count {
            pairs.append((players[i], players[i + 1]))
            i += 2
        }
    }

    func processMatch(winner: Player, loser: Player) {
        guard let winnerIndex = players.firstIndex(where: { $0.id == winner.id }),
              let loserIndex = players.firstIndex(where: { $0.id == loser.id }) else { return }

        let r1 = Double(players[winnerIndex].rating)
        let r2 = Double(players[loserIndex].rating)

        let expected1 = 1 / (1 + pow(10, (r2 - r1) / 10))  // same formula as your Python version
        let expected2 = 1 - expected1

        let k = 32.0
        let newR1 = r1 + k * (1 - expected1)
        let newR2 = r2 + k * (0 - expected2)

        players[winnerIndex].rating = Int(newR1)
        players[loserIndex].rating = Int(newR2)

        currentPairIndex += 1
    }
    
    // Reset the game state
        func resetGame() {
            round = 1
            currentPairIndex = 0
            showLeaderboard = false
            players = players
            nameInput = ""
        }
}
