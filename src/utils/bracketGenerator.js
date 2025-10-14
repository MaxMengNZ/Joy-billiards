/**
 * Tournament Bracket Generator
 * Automatically generates matches based on tournament type
 */

/**
 * Shuffle array randomly (for random seeding)
 */
function shuffleArray(array) {
  const shuffled = [...array]
  for (let i = shuffled.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]]
  }
  return shuffled
}

/**
 * Generate Double Elimination bracket - Standard Format
 * 标准双败赛制：胜者组 + 败者组（按照标准锦标赛格式）
 */
export function generateDoubleElimination(players) {
  if (players.length < 2) {
    return { error: 'Need at least 2 players' }
  }

  if (players.length !== 16) {
    return { error: 'Double elimination currently supports 16 players only' }
  }

  // Shuffle players randomly for draw
  const shuffledPlayers = shuffleArray([...players])
  const matches = []

  // WINNERS BRACKET (胜者组)
  
  // Winners Round 1: Match 1-8 (16 players)
  for (let i = 0; i < 8; i++) {
    matches.push({
      round_number: 1,
      match_number: i + 1,
      player1_id: shuffledPlayers[i * 2]?.id || null,
      player2_id: shuffledPlayers[i * 2 + 1]?.id || null,
      status: 'scheduled',
      bracket_type: 'winners',
      notes: `Match ${i + 1}: Winners Round 1`
    })
  }

  // Winners Round 2: Match 13-16 (8 → 4)
  for (let i = 0; i < 4; i++) {
    matches.push({
      round_number: 2,
      match_number: 13 + i,
      player1_id: null, // TBD: Winner of Match (i*2+1)
      player2_id: null, // TBD: Winner of Match (i*2+2)
      status: 'scheduled',
      bracket_type: 'winners',
      notes: `Match ${13 + i}: Winners Round 2 (Winner of ${i*2+1} vs Winner of ${i*2+2})`
    })
  }

  // Winners Round 3: Match 21-22 (4 → 2)
  for (let i = 0; i < 2; i++) {
    matches.push({
      round_number: 3,
      match_number: 21 + i,
      player1_id: null, // TBD: Winner of Match (13+i*2)
      player2_id: null, // TBD: Winner of Match (14+i*2)
      status: 'scheduled',
      bracket_type: 'winners',
      notes: `Match ${21 + i}: Winners Round 3 (Winner of ${13+i*2} vs Winner of ${14+i*2})`
    })
  }

  // Winners Final: Match 27 (2 → 1)
  matches.push({
    round_number: 4,
    match_number: 27,
    player1_id: null, // TBD: Winner of Match 21
    player2_id: null, // TBD: Winner of Match 22
    status: 'scheduled',
    bracket_type: 'winners',
    notes: 'Match 27: Winners Final (Winner of 21 vs Winner of 22)'
  })

  // LOSERS BRACKET (败者组)

  // Losers Round 1: Match 9-12 (Losers from Winners Round 1)
  const losersPairs = [
    { match: 9, from: [1, 2] },
    { match: 10, from: [3, 4] },
    { match: 11, from: [5, 6] },
    { match: 12, from: [7, 8] }
  ]
  
  losersPairs.forEach(pair => {
    matches.push({
      round_number: 1,
      match_number: pair.match,
      player1_id: null, // TBD: Loser of Match pair.from[0]
      player2_id: null, // TBD: Loser of Match pair.from[1]
      status: 'scheduled',
      bracket_type: 'losers',
      notes: `Match ${pair.match}: Losers Round 1 (Loser of ${pair.from[0]} vs Loser of ${pair.from[1]})`
    })
  })

  // Losers Round 2: Match 17-20 (Losers from Winners Round 2 vs Winners from Losers Round 1)
  const losersRound2 = [
    { match: 17, winnerFrom: 16, loserFrom: 9 },
    { match: 18, winnerFrom: 15, loserFrom: 10 },
    { match: 19, winnerFrom: 14, loserFrom: 11 },
    { match: 20, winnerFrom: 13, loserFrom: 12 }
  ]
  
  losersRound2.forEach(pair => {
    matches.push({
      round_number: 2,
      match_number: pair.match,
      player1_id: null, // TBD: Loser of Match pair.winnerFrom
      player2_id: null, // TBD: Winner of Match pair.loserFrom
      status: 'scheduled',
      bracket_type: 'losers',
      notes: `Match ${pair.match}: Losers Round 2 (Loser of ${pair.winnerFrom} vs Winner of ${pair.loserFrom})`
    })
  })

  // Losers Round 3: Match 23-24 (Winners from Losers Round 2)
  for (let i = 0; i < 2; i++) {
    matches.push({
      round_number: 3,
      match_number: 23 + i,
      player1_id: null, // TBD: Winner of Match (17+i*2)
      player2_id: null, // TBD: Winner of Match (18+i*2)
      status: 'scheduled',
      bracket_type: 'losers',
      notes: `Match ${23 + i}: Losers Round 3 (Winner of ${17+i*2} vs Winner of ${18+i*2})`
    })
  }

  // Losers Round 4: Match 25-26 (Losers from Winners Round 3 vs Winners from Losers Round 3)
  const losersRound4 = [
    { match: 25, winnerFrom: 21, loserFrom: 23 },
    { match: 26, winnerFrom: 22, loserFrom: 24 }
  ]
  
  losersRound4.forEach(pair => {
    matches.push({
      round_number: 4,
      match_number: pair.match,
      player1_id: null, // TBD: Loser of Match pair.winnerFrom
      player2_id: null, // TBD: Winner of Match pair.loserFrom
      status: 'scheduled',
      bracket_type: 'losers',
      notes: `Match ${pair.match}: Losers Round 4 (Loser of ${pair.winnerFrom} vs Winner of ${pair.loserFrom})`
    })
  })

  // Losers Round 5: Match 28 (Winners from Losers Round 4)
  matches.push({
    round_number: 5,
    match_number: 28,
    player1_id: null, // TBD: Winner of Match 25
    player2_id: null, // TBD: Winner of Match 26
    status: 'scheduled',
    bracket_type: 'losers',
    notes: 'Match 28: Losers Round 5 (Winner of 25 vs Winner of 26)'
  })

  // Losers Final: Match 29 (Loser from Winners Final vs Winner from Losers Round 5)
  matches.push({
    round_number: 6,
    match_number: 29,
    player1_id: null, // TBD: Loser of Match 27
    player2_id: null, // TBD: Winner of Match 28
    status: 'scheduled',
    bracket_type: 'losers',
    notes: 'Match 29: Losers Final (Loser of 27 vs Winner of 28)'
  })

  // GRAND FINAL: Match 30 (Winners Champion vs Losers Champion)
  matches.push({
    round_number: 7,
    match_number: 30,
    player1_id: null, // TBD: Winner of Match 27 (Winners Champion)
    player2_id: null, // TBD: Winner of Match 29 (Losers Champion)
    status: 'scheduled',
    bracket_type: 'grand_final',
    notes: 'Match 30: Grand Final (Winner of 27 vs Winner of 29)'
  })

  return {
    matches,
    totalRounds: 7,
    playersCount: players.length,
    winnersRounds: 4,
    losersRounds: 6,
    shuffledPlayers: shuffledPlayers,
    bracketType: 'double_elimination'
  }
}

/**
 * Generate Single Elimination bracket with random draw
 * 每次随机生成不同的对阵
 */
export function generateSingleElimination(players) {
  if (players.length < 2) {
    return { error: 'Need at least 2 players' }
  }

  // For 16 players, we need exactly 16 spots
  const totalRounds = 4 // Round 1, Quarter-Finals, Semi-Finals, Finals
  const totalMatches = 15 // 8 + 4 + 2 + 1

  // Shuffle players randomly for draw
  const shuffledPlayers = shuffleArray([...players])
  
  const matches = []
  let matchNumber = 1

  // Round 1: 8 matches with randomly paired players (16 → 8)
  for (let i = 0; i < shuffledPlayers.length; i += 2) {
    if (i + 1 < shuffledPlayers.length) {
      matches.push({
        round_number: 1,
        match_number: matchNumber++,
        player1_id: shuffledPlayers[i]?.id || null,
        player2_id: shuffledPlayers[i + 1]?.id || null,
        status: 'scheduled'
      })
    }
  }

  // Quarter-Finals: 4 matches with TBD (8 → 4)
  for (let i = 0; i < 4; i++) {
    matches.push({
      round_number: 2,
      match_number: matchNumber++,
      player1_id: null, // TBD
      player2_id: null, // TBD
      status: 'scheduled'
    })
  }

  // Semi-Finals: 2 matches with TBD (4 → 2)
  for (let i = 0; i < 2; i++) {
    matches.push({
      round_number: 3,
      match_number: matchNumber++,
      player1_id: null, // TBD
      player2_id: null, // TBD
      status: 'scheduled'
    })
  }

  // Finals: 1 match with TBD (2 → 1)
  matches.push({
    round_number: 4,
    match_number: matchNumber++,
    player1_id: null, // TBD
    player2_id: null, // TBD
    status: 'scheduled'
  })

  return {
    matches,
    totalRounds,
    playersCount: players.length,
    bracketSize: 16,
    shuffledPlayers: shuffledPlayers
  }
}

/**
 * Generate Round Robin (everyone plays everyone)
 */
export function generateRoundRobin(players) {
  if (players.length < 2) {
    return { error: 'Need at least 2 players' }
  }

  const matches = []
  let matchNumber = 1

  // Generate all possible pairings
  for (let i = 0; i < players.length; i++) {
    for (let j = i + 1; j < players.length; j++) {
      matches.push({
        round_number: 1, // All matches in same "round" for round robin
        match_number: matchNumber++,
        player1_id: players[i].id,
        player2_id: players[j].id,
        status: 'scheduled'
      })
    }
  }

  return {
    matches,
    totalRounds: 1,
    playersCount: players.length,
    totalMatches: (players.length * (players.length - 1)) / 2
  }
}


/**
 * Generate Swiss System (based on rankings)
 */
export function generateSwissRound(players, roundNumber) {
  if (players.length < 2) {
    return { error: 'Need at least 2 players' }
  }

  // Sort by ranking level (Swiss pairing)
  const rankingOrder = {
    'beginner': 1,
    'intermediate': 2,
    'advance': 3,
    'expert': 4,
    'elite': 5,
    'master': 6,
    'grand_master': 7,
    'pro_level': 8,
    'hall_of_fame': 9
  }
  const sorted = [...players].sort((a, b) => {
    const aLevel = rankingOrder[a.ranking_level] || 1
    const bLevel = rankingOrder[b.ranking_level] || 1
    return bLevel - aLevel
  })
  
  const matches = []
  let matchNumber = 1

  // Pair adjacent players in ranking
  for (let i = 0; i < sorted.length; i += 2) {
    if (i + 1 < sorted.length) {
      matches.push({
        round_number: roundNumber,
        match_number: matchNumber++,
        player1_id: sorted[i].id,
        player2_id: sorted[i + 1].id,
        status: 'scheduled'
      })
    } else {
      // Odd player gets a bye
      console.log(`Player ${sorted[i].name} gets a bye in round ${roundNumber}`)
    }
  }

  return {
    matches,
    roundNumber,
    playersCount: players.length
  }
}

/**
 * Main generator function
 */
export function generateTournamentMatches(tournamentType, players, roundNumber = 1) {
  switch (tournamentType) {
    case 'single_elimination':
      return generateSingleElimination(players)
    
    case 'double_elimination':
      return generateDoubleElimination(players)
    
    case 'round_robin':
      return generateRoundRobin(players)
    
    case 'swiss':
      return generateSwissRound(players, roundNumber)
    
    default:
      return { error: 'Unknown tournament type' }
  }
}

/**
 * Calculate handicap based on ranking difference
 */
export function calculateHandicap(player1RankLevel, player2RankLevel) {
  const rankOrder = {
    'beginner': 0,
    'intermediate': 1,
    'advance': 2,
    'expert': 3,
    'elite': 4,
    'master': 5,
    'grand_master': 6,
    'pro_level': 7,
    'hall_of_fame': 8
  }

  const rank1 = rankOrder[player1RankLevel] || 0
  const rank2 = rankOrder[player2RankLevel] || 0
  const diff = Math.abs(rank1 - rank2)

  if (diff <= 1) return 0
  if (diff <= 3) return 1
  if (diff <= 5) return 2
  return 3
}

