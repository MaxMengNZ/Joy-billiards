<template>
  <div class="tournament-bracket">
    <div class="bracket-header">
      <h3>Single Elimination Bracket</h3>
      <div v-if="raceToScore" class="race-info">
        <span class="race-badge">Race to {{ raceToScore }}</span>
      </div>
    </div>

    <div v-if="matches.length === 0" class="no-bracket">
      <p>No matches generated yet. Click "Auto Generate Matches" to create the bracket.</p>
    </div>

    <div v-else class="bracket-container">
      <!-- Winners Bracket Section -->
      <div v-if="winnersRounds.length > 0" class="bracket-section">
        <h3 class="bracket-section-title">🏆 Winners Bracket</h3>
        <div class="bracket-grid">
          <!-- Winners Round Headers -->
          <div class="round-headers">
            <div 
              v-for="(round, roundIndex) in winnersRounds" 
              :key="'winners-header-' + roundIndex"
              class="round-header"
            >
              {{ round.title.toUpperCase() }}
            </div>
          </div>

          <!-- Winners Bracket Structure -->
          <div class="bracket-structure">
            <div 
              v-for="(round, roundIndex) in winnersRounds" 
              :key="'winners-round-' + roundIndex"
              class="bracket-column"
            >
              <div class="match-slots">
                <div 
                  v-for="(match, matchIndex) in round.matches" 
                  :key="match.id"
                  class="match-slot"
                  :class="[match.status, `round-${round.number}`, 'winners']"
                  :style="{ '--match-index': matchIndex }"
                >
                  <!-- Match Title -->
                  <div class="match-title">
                    Match {{ match.match_number }}
                    <span class="bracket-type">🏆</span>
                  </div>
                
                <!-- Player 1 -->
                <div class="player-slot" :class="{ winner: match.winner_id === match.player1_id }">
                  <span 
                    class="player-name" 
                    :class="{ 'clickable-winner': isAdmin && match.player1_id && match.status !== 'completed' }"
                    @click="isAdmin && match.player1_id && match.status !== 'completed' ? setWinner(match, 'player1') : null"
                    :title="isAdmin && match.player1_id && match.status !== 'completed' ? 'Click to set as winner' : ''"
                  >
                    {{ getPlayerDisplayName(match, 'player1') }}
                  </span>
                  <span 
                    v-if="match.player1_id"
                    class="player-score clickable-score" 
                    :class="{ 'editable': isAdmin }"
                    @click="isAdmin ? editScore(match, 'player1') : null"
                    :title="isAdmin ? 'Click to edit score' : ''"
                  >
                    {{ match.player1_score || 0 }}
                  </span>
                  <span v-else class="player-score tbd">-</span>
                </div>
                
                <!-- Player 2 -->
                <div class="player-slot" :class="{ winner: match.winner_id === match.player2_id }">
                  <span 
                    class="player-name" 
                    :class="{ 'clickable-winner': isAdmin && match.player2_id && match.status !== 'completed' }"
                    @click="isAdmin && match.player2_id && match.status !== 'completed' ? setWinner(match, 'player2') : null"
                    :title="isAdmin && match.player2_id && match.status !== 'completed' ? 'Click to set as winner' : ''"
                  >
                    {{ getPlayerDisplayName(match, 'player2') }}
                  </span>
                  <span 
                    v-if="match.player2_id"
                    class="player-score clickable-score" 
                    :class="{ 'editable': isAdmin }"
                    @click="isAdmin ? editScore(match, 'player2') : null"
                    :title="isAdmin ? 'Click to edit score' : ''"
                  >
                    {{ match.player2_score || 0 }}
                  </span>
                  <span v-else class="player-score tbd">-</span>
                </div>
                
                <!-- Advance Winner Button -->
                <div v-if="isAdmin && match.status === 'completed' && match.winner_id && match.round_number < 4" class="match-actions">
                  <button 
                    class="btn-advance"
                    @click="advanceWinner(match)"
                    :title="`Advance ${getPlayerName(match.winner_id)} to next round`"
                  >
                    ⬆️ Advance Winner
                  </button>
                </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Losers Bracket Section -->
      <div v-if="losersRounds.length > 0" class="bracket-section">
        <h3 class="bracket-section-title">💀 Losers Bracket</h3>
        <div class="bracket-grid">
          <!-- Losers Round Headers -->
          <div class="round-headers">
            <div 
              v-for="(round, roundIndex) in losersRounds" 
              :key="'losers-header-' + roundIndex"
              class="round-header"
            >
              {{ round.title.toUpperCase() }}
            </div>
          </div>

          <!-- Losers Bracket Structure -->
          <div class="bracket-structure">
            <div 
              v-for="(round, roundIndex) in losersRounds" 
              :key="'losers-round-' + roundIndex"
              class="bracket-column"
            >
              <div class="match-slots">
                <div 
                  v-for="(match, matchIndex) in round.matches" 
                  :key="match.id"
                  class="match-slot"
                  :class="[match.status, `round-${round.number}`, 'losers']"
                  :style="{ '--match-index': matchIndex }"
                >
                  <!-- Match Title -->
                  <div class="match-title">
                    Match {{ match.match_number }}
                    <span class="bracket-type">💀</span>
                  </div>
                
                <!-- Player 1 -->
                <div class="player-slot" :class="{ winner: match.winner_id === match.player1_id }">
                  <span 
                    class="player-name" 
                    :class="{ 'clickable-winner': isAdmin && match.player1_id && match.status !== 'completed' }"
                    @click="isAdmin && match.player1_id && match.status !== 'completed' ? setWinner(match, 'player1') : null"
                    :title="isAdmin && match.player1_id && match.status !== 'completed' ? 'Click to set as winner' : ''"
                  >
                    {{ getPlayerDisplayName(match, 'player1') }}
                  </span>
                  <span 
                    v-if="match.player1_id"
                    class="player-score clickable-score" 
                    :class="{ 'editable': isAdmin }"
                    @click="isAdmin ? editScore(match, 'player1') : null"
                    :title="isAdmin ? 'Click to edit score' : ''"
                  >
                    {{ match.player1_score || 0 }}
                  </span>
                  <span v-else class="player-score tbd">-</span>
                </div>
                
                <!-- Player 2 -->
                <div class="player-slot" :class="{ winner: match.winner_id === match.player2_id }">
                  <span 
                    class="player-name" 
                    :class="{ 'clickable-winner': isAdmin && match.player2_id && match.status !== 'completed' }"
                    @click="isAdmin && match.player2_id && match.status !== 'completed' ? setWinner(match, 'player2') : null"
                    :title="isAdmin && match.player2_id && match.status !== 'completed' ? 'Click to set as winner' : ''"
                  >
                    {{ getPlayerDisplayName(match, 'player2') }}
                  </span>
                  <span 
                    v-if="match.player2_id"
                    class="player-score clickable-score" 
                    :class="{ 'editable': isAdmin }"
                    @click="isAdmin ? editScore(match, 'player2') : null"
                    :title="isAdmin ? 'Click to edit score' : ''"
                  >
                    {{ match.player2_score || 0 }}
                  </span>
                  <span v-else class="player-score tbd">-</span>
                </div>
                
                <!-- Advance Winner Button -->
                <div v-if="isAdmin && match.status === 'completed' && match.winner_id && match.bracket_type !== 'grand_final'" class="match-actions">
                  <button 
                    class="btn-advance"
                    @click="advanceWinner(match)"
                    :title="`Advance ${getPlayerName(match.winner_id)} to next round`"
                  >
                    ⬆️ Advance Winner
                  </button>
                </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Grand Final Section -->
      <div v-if="grandFinalRounds.length > 0" class="bracket-section">
        <h3 class="bracket-section-title">👑 Grand Final</h3>
        <div class="bracket-grid">
          <div class="round-headers">
            <div class="round-header">GRAND FINAL</div>
          </div>
          <div class="bracket-structure">
            <div class="bracket-column">
              <div class="match-slots">
                <div 
                  v-for="(match, matchIndex) in grandFinalRounds[0].matches" 
                  :key="match.id"
                  class="match-slot grand-final"
                  :class="[match.status]"
                >
                  <div class="match-title">
                    Match {{ match.match_number }}
                    <span class="bracket-type">👑</span>
                  </div>
                
                <!-- Player 1 -->
                <div class="player-slot" :class="{ winner: match.winner_id === match.player1_id }">
                  <span 
                    class="player-name" 
                    :class="{ 'clickable-winner': isAdmin && match.player1_id && match.status !== 'completed' }"
                    @click="isAdmin && match.player1_id && match.status !== 'completed' ? setWinner(match, 'player1') : null"
                    :title="isAdmin && match.player1_id && match.status !== 'completed' ? 'Click to set as winner' : ''"
                  >
                    {{ getPlayerDisplayName(match, 'player1') }}
                  </span>
                  <span 
                    v-if="match.player1_id"
                    class="player-score clickable-score" 
                    :class="{ 'editable': isAdmin }"
                    @click="isAdmin ? editScore(match, 'player1') : null"
                    :title="isAdmin ? 'Click to edit score' : ''"
                  >
                    {{ match.player1_score || 0 }}
                  </span>
                  <span v-else class="player-score tbd">-</span>
                </div>
                
                <!-- Player 2 -->
                <div class="player-slot" :class="{ winner: match.winner_id === match.player2_id }">
                  <span 
                    class="player-name" 
                    :class="{ 'clickable-winner': isAdmin && match.player2_id && match.status !== 'completed' }"
                    @click="isAdmin && match.player2_id && match.status !== 'completed' ? setWinner(match, 'player2') : null"
                    :title="isAdmin && match.player2_id && match.status !== 'completed' ? 'Click to set as winner' : ''"
                  >
                    {{ getPlayerDisplayName(match, 'player2') }}
                  </span>
                  <span 
                    v-if="match.player2_id"
                    class="player-score clickable-score" 
                    :class="{ 'editable': isAdmin }"
                    @click="isAdmin ? editScore(match, 'player2') : null"
                    :title="isAdmin ? 'Click to edit score' : ''"
                  >
                    {{ match.player2_score || 0 }}
                  </span>
                  <span v-else class="player-score tbd">-</span>
                </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div v-if="rounds.length > 2" class="bracket-scroll-hint">
      ← Scroll horizontally to view all rounds →
    </div>
  </div>
</template>

<script>
import { computed } from 'vue'

export default {
  name: 'TournamentBracket',
  props: {
    matches: {
      type: Array,
      required: true
    },
    players: {
      type: Array,
      default: () => []
    },
    tournamentType: {
      type: String,
      default: 'single_elimination'
    },
    isAdmin: {
      type: Boolean,
      default: false
    },
    raceToScore: {
      type: Number,
      default: 5
    }
  },
  emits: ['update-score', 'advance-winner', 'set-winner'],
  setup(props, { emit }) {
    const rounds = computed(() => {
      if (!props.matches || props.matches.length === 0) return []

      const roundsMap = {}
      props.matches.forEach(match => {
        const roundNum = match.round_number || 1
        if (!roundsMap[roundNum]) {
          roundsMap[roundNum] = {
            number: roundNum,
            matches: []
          }
        }
        roundsMap[roundNum].matches.push(match)
      })

      // Add round titles
      const sortedRounds = Object.values(roundsMap).sort((a, b) => a.number - b.number)
      const totalRounds = sortedRounds.length

      return sortedRounds.map((round, index) => ({
        ...round,
        title: getRoundTitle(round.number, totalRounds, props.tournamentType)
      }))
    })

    // Separate rounds by bracket type
    const winnersRounds = computed(() => {
      if (!props.matches || props.matches.length === 0) return []
      
      const winnersMatches = props.matches.filter(match => match.bracket_type === 'winners')
      const roundsMap = {}
      
      winnersMatches.forEach(match => {
        const roundNum = match.round_number || 1
        if (!roundsMap[roundNum]) {
          roundsMap[roundNum] = {
            number: roundNum,
            matches: []
          }
        }
        roundsMap[roundNum].matches.push(match)
      })

      return Object.values(roundsMap)
        .sort((a, b) => a.number - b.number)
        .map(round => ({
          ...round,
          title: getWinnersRoundTitle(round.number)
        }))
    })

    const losersRounds = computed(() => {
      if (!props.matches || props.matches.length === 0) return []
      
      const losersMatches = props.matches.filter(match => match.bracket_type === 'losers')
      const roundsMap = {}
      
      losersMatches.forEach(match => {
        const roundNum = match.round_number || 1
        if (!roundsMap[roundNum]) {
          roundsMap[roundNum] = {
            number: roundNum,
            matches: []
          }
        }
        roundsMap[roundNum].matches.push(match)
      })

      return Object.values(roundsMap)
        .sort((a, b) => a.number - b.number)
        .map(round => ({
          ...round,
          title: getLosersRoundTitle(round.number)
        }))
    })

    const grandFinalRounds = computed(() => {
      if (!props.matches || props.matches.length === 0) return []
      
      const grandFinalMatches = props.matches.filter(match => match.bracket_type === 'grand_final')
      if (grandFinalMatches.length === 0) return []

      return [{
        number: 1,
        matches: grandFinalMatches,
        title: 'Grand Final'
      }]
    })

    const getRoundTitle = (roundNumber, totalRounds, tournamentType) => {
      if (tournamentType === 'round_robin') {
        return 'Round Robin'
      }
      
      if (tournamentType === 'swiss') {
        return `Round ${roundNumber}`
      }

      // For single elimination tournaments
      if (roundNumber === totalRounds) {
        return 'Finals'
      } else if (roundNumber === totalRounds - 1) {
        return 'Semi-Finals'
      } else if (roundNumber === totalRounds - 2) {
        return 'Quarter-Finals'
      } else {
        return `Round ${roundNumber}`
      }
    }

    const getWinnersRoundTitle = (roundNumber) => {
      if (roundNumber === 4) {
        return 'Winners Final'
      } else if (roundNumber === 3) {
        return 'Semi-Finals'
      } else if (roundNumber === 2) {
        return 'Quarter-Finals'
      } else {
        return `Round ${roundNumber}`
      }
    }

    const getLosersRoundTitle = (roundNumber) => {
      if (roundNumber === 6) {
        return 'Losers Finals'
      } else if (roundNumber === 5) {
        return 'Losers Round 5'
      } else if (roundNumber === 4) {
        return 'Losers Round 4'
      } else if (roundNumber === 3) {
        return 'Losers Round 3'
      } else if (roundNumber === 2) {
        return 'Losers Round 2'
      } else {
        return 'Losers Round 1'
      }
    }

    const getPlayerName = (playerId) => {
      if (!playerId) return 'TBD'
      const player = props.players.find(p => p.id === playerId)
      return player ? player.name : 'TBD'
    }

    const getPlayerDisplayName = (match, playerType) => {
      const playerId = match[`${playerType}_id`]
      if (!playerId) {
        // For losers bracket, show "Loser of X" format
        if (match.bracket_type === 'losers') {
          return getLoserDisplayName(match, playerType)
        }
        return 'TBD'
      }
      return getPlayerName(playerId)
    }

    const getLoserDisplayName = (match, playerType) => {
      // This is a simplified version - in a real implementation,
      // you'd need to track which matches feed into this losers bracket match
      const matchNum = match.match_number
      
      // Losers Round 1: Loser of 1 vs Loser of 2, etc.
      if (match.round_number === 1) {
        if (playerType === 'player1') {
          return `Loser of ${matchNum - 8}` // WB matches are 1-8, LR1 matches start at 9
        } else {
          return `Loser of ${matchNum - 7}`
        }
      }
      
      // For other rounds, show generic "TBD"
      return 'TBD'
    }

    const editScore = (match, playerType) => {
      if (!props.isAdmin) return
      
      emit('update-score', {
        match,
        playerType
      })
    }

    const advanceWinner = (match) => {
      if (!props.isAdmin) return
      
      emit('advance-winner', match)
    }

    const setWinner = (match, playerType) => {
      if (!props.isAdmin) return
      
      const playerName = getPlayerName(match[`${playerType}_id`])
      const confirmMsg = `Set ${playerName} as the winner of this match?`
      
      if (confirm(confirmMsg)) {
        emit('set-winner', {
          match,
          playerType
        })
      }
    }

    return {
      rounds,
      winnersRounds,
      losersRounds,
      grandFinalRounds,
      getPlayerName,
      getPlayerDisplayName,
      editScore,
      advanceWinner,
      setWinner
    }
  }
}
</script>

<style scoped>
.tournament-bracket {
  background: #2c2c2c;
  border-radius: 12px;
  padding: 2rem;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
  color: white;
  margin-bottom: 2rem;
}

.bracket-header {
  text-align: center;
  margin-bottom: 2rem;
  padding-bottom: 1rem;
  border-bottom: 2px solid #444;
}

.bracket-header h3 {
  font-size: 1.75rem;
  font-weight: 700;
  color: white;
  margin: 0;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.5);
}

.race-info {
  margin-top: 0.5rem;
}

.race-badge {
  display: inline-block;
  padding: 0.5rem 1rem;
  background: linear-gradient(135deg, #ff6b35, #f7931e);
  color: white;
  border-radius: 20px;
  font-size: 0.875rem;
  font-weight: 600;
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.3);
  box-shadow: 0 2px 8px rgba(255, 107, 53, 0.3);
}

.no-bracket {
  text-align: center;
  padding: 3rem;
  color: #ccc;
  font-size: 1.1rem;
}

.bracket-container {
  overflow-x: auto;
  padding: 1rem 0;
}

.bracket-section {
  margin-bottom: 3rem;
}

.bracket-section:last-child {
  margin-bottom: 0;
}

.bracket-section-title {
  font-size: 1.5rem;
  font-weight: 700;
  color: #fff;
  text-align: center;
  margin: 0 0 2rem 0;
  padding: 1rem;
  background: linear-gradient(135deg, #333, #444);
  border-radius: 8px;
  border: 2px solid #555;
}

.bracket-grid {
  min-width: 1400px;
  display: flex;
  flex-direction: column;
  gap: 2rem;
}

.round-headers {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 2rem;
  gap: 1rem;
}

.round-header {
  font-size: 1.125rem;
  font-weight: 700;
  color: #fff;
  text-align: center;
  min-width: 220px;
  padding: 0.75rem 1rem;
  background: linear-gradient(135deg, #444, #333);
  border-radius: 8px;
  border: 2px solid #555;
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.5);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
}

.bracket-structure {
  display: flex;
  justify-content: flex-start;
  align-items: flex-start;
  position: relative;
  padding: 2rem;
  gap: 4rem;
  min-height: 1400px;
}

.bracket-column {
  min-width: 220px;
  display: flex;
  flex-direction: column;
  position: relative;
  flex-shrink: 0;
}

.match-slots {
  display: flex;
  flex-direction: column;
  width: 100%;
  position: relative;
}

/* 定义基础变量 */
/* match高度: 110px, gap: 20px, 单元格: 130px */

/* Round 1: 8 matches - Base level, 20px gap between matches */
.bracket-column:nth-child(1) .match-slots {
  gap: 20px;
}

/* Quarter-Finals: 4 matches - Center between pairs */
.bracket-column:nth-child(2) .match-slots {
  gap: 0;
}

/* QF Match 1: center of R1 Match 1 & 2 */
.bracket-column:nth-child(2) .match-slot:nth-child(1) {
  margin-top: 65px; /* (110 + 20) / 2 */
  margin-bottom: 150px; /* 130 + 20 (skip R1 match 3 & 4) */
}

/* QF Match 2: center of R1 Match 3 & 4 */
.bracket-column:nth-child(2) .match-slot:nth-child(2) {
  margin-bottom: 150px;
}

/* QF Match 3: center of R1 Match 5 & 6 */
.bracket-column:nth-child(2) .match-slot:nth-child(3) {
  margin-bottom: 150px;
}

/* QF Match 4: center of R1 Match 7 & 8 */
.bracket-column:nth-child(2) .match-slot:nth-child(4) {
  margin-bottom: 0;
}

/* Semi-Finals: 2 matches - Center between QF pairs */
.bracket-column:nth-child(3) .match-slots {
  gap: 0;
}

/* SF Match 1: center of QF Match 1 & 2 */
.bracket-column:nth-child(3) .match-slot:nth-child(1) {
  margin-top: 230px; /* 65 + 55 + 110 */
  margin-bottom: 430px; /* skip to SF Match 2 */
}

/* SF Match 2: center of QF Match 3 & 4 */
.bracket-column:nth-child(3) .match-slot:nth-child(2) {
  margin-bottom: 0;
}

/* Finals: 1 match - Center between SF matches */
.bracket-column:nth-child(4) .match-slots {
  gap: 0;
}

.bracket-column:nth-child(4) .match-slot {
  margin-top: 445px; /* center of SF Match 1 & 2 */
}

.match-slot {
  background: #333;
  border: 2px solid #555;
  border-radius: 10px;
  padding: 0.75rem;
  min-height: 110px;
  width: 200px;
  position: relative;
  transition: all 0.3s ease;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.2);
}

.match-title {
  font-size: 0.75rem;
  font-weight: 600;
  color: #888;
  text-align: center;
  margin-bottom: 0.5rem;
  padding-bottom: 0.25rem;
  border-bottom: 1px solid #444;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.bracket-type {
  font-size: 0.875rem;
}

.bracket-type-badge {
  font-size: 0.625rem;
  color: #aaa;
  margin-top: 0.25rem;
}

.match-slot:hover {
  border-color: #007bff;
  box-shadow: 0 4px 12px rgba(0, 123, 255, 0.3);
}

.match-slot.scheduled {
  background: #333;
  border-color: #555;
}

.match-slot.in_progress {
  background: linear-gradient(135deg, #ffc107, #ff8f00);
  border-color: #ffc107;
  animation: pulse 2s infinite;
}

.match-slot.completed {
  background: linear-gradient(135deg, #28a745, #20c997);
  border-color: #28a745;
}

/* Double Elimination Bracket Types */
.match-slot.winners {
  border-left: 4px solid #28a745;
}

.match-slot.losers {
  border-left: 4px solid #dc3545;
}

.match-slot.grand_final {
  border-left: 4px solid #ffc107;
  background: linear-gradient(135deg, #333, #444);
}

@keyframes pulse {
  0%, 100% { opacity: 1; transform: scale(1); }
  50% { opacity: 0.9; transform: scale(1.02); }
}

.player-slot {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.5rem 0.75rem;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 4px;
  margin-bottom: 0.25rem;
  border-left: 3px solid transparent;
  transition: all 0.3s ease;
}

.player-slot:last-child {
  margin-bottom: 0;
}

.player-slot.winner {
  background: rgba(255, 215, 0, 0.2);
  border-left-color: #ffd700;
  font-weight: 700;
  color: #ffd700;
}

.player-name {
  flex: 1;
  font-size: 0.875rem;
  font-weight: 500;
  color: white;
  text-overflow: ellipsis;
  transition: all 0.2s ease;
}

.player-name.clickable-winner {
  cursor: pointer;
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  background: rgba(255, 193, 7, 0.1);
  border: 1px solid rgba(255, 193, 7, 0.3);
}

.player-name.clickable-winner:hover {
  background: rgba(255, 193, 7, 0.2);
  border-color: rgba(255, 193, 7, 0.5);
  color: #ffc107;
  transform: scale(1.05);
  overflow: hidden;
  white-space: nowrap;
}

.player-score {
  font-size: 1rem;
  font-weight: 700;
  color: #fff;
  margin-left: 0.5rem;
  min-width: 20px;
  text-align: center;
}

.player-slot.winner .player-score {
  color: #ffd700;
}

.clickable-score.editable {
  cursor: pointer;
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  background: rgba(255, 255, 255, 0.1);
  border: 2px solid transparent;
  transition: all 0.3s ease;
}

.clickable-score.editable:hover {
  background: rgba(0, 123, 255, 0.2);
  border-color: #007bff;
  transform: scale(1.1);
  box-shadow: 0 2px 8px rgba(0, 123, 255, 0.3);
}

.clickable-score.editable:active {
  transform: scale(0.95);
}

.player-score.tbd {
  color: #999;
  font-style: italic;
  cursor: default;
}

.match-actions {
  margin-top: 0.5rem;
  text-align: center;
}

.btn-advance {
  background: linear-gradient(135deg, #28a745, #20c997);
  color: white;
  border: none;
  padding: 0.5rem 0.75rem;
  border-radius: 6px;
  font-size: 0.75rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 2px 4px rgba(40, 167, 69, 0.3);
}

.btn-advance:hover {
  background: linear-gradient(135deg, #20c997, #28a745);
  transform: translateY(-2px);
  box-shadow: 0 4px 8px rgba(40, 167, 69, 0.5);
}

.btn-advance:active {
  transform: translateY(0);
}

.bracket-scroll-hint {
  text-align: center;
  margin-top: 1rem;
  color: #ccc;
  font-size: 0.875rem;
  font-style: italic;
}

/* Connection Lines - Perfect Tree Structure */

/* Horizontal lines from each match center to next round */
.bracket-column:not(:last-child) .match-slot::after {
  content: '';
  position: absolute;
  top: 50%;
  right: -4rem;
  width: 4rem;
  height: 2px;
  background: #888;
  z-index: 2;
  transform: translateY(-1px);
}

/* ===== Round 1 → Quarter-Finals ===== */
/* Odd matches (1,3,5,7) - line goes down */
.bracket-column:nth-child(1) .match-slot:nth-child(odd)::before {
  content: '';
  position: absolute;
  top: 50%;
  right: -4rem;
  width: 2px;
  height: 65px; /* distance to middle between this and next match */
  background: #888;
  z-index: 1;
}

/* Even matches (2,4,6,8) - line goes up */
.bracket-column:nth-child(1) .match-slot:nth-child(even)::before {
  content: '';
  position: absolute;
  bottom: 50%;
  right: -4rem;
  width: 2px;
  height: 65px; /* distance to middle between this and previous match */
  background: #888;
  z-index: 1;
}

/* ===== Quarter-Finals → Semi-Finals ===== */
/* QF Match 1 & 3 - line goes down */
.bracket-column:nth-child(2) .match-slot:nth-child(1)::before,
.bracket-column:nth-child(2) .match-slot:nth-child(3)::before {
  content: '';
  position: absolute;
  top: 50%;
  right: -4rem;
  width: 2px;
  height: 215px; /* 150 (margin-bottom) + 65 (half of next match position) */
  background: #888;
  z-index: 1;
}

/* QF Match 2 & 4 - line goes up */
.bracket-column:nth-child(2) .match-slot:nth-child(2)::before,
.bracket-column:nth-child(2) .match-slot:nth-child(4)::before {
  content: '';
  position: absolute;
  bottom: 50%;
  right: -4rem;
  width: 2px;
  height: 215px;
  background: #888;
  z-index: 1;
}

/* ===== Semi-Finals → Finals ===== */
/* SF Match 1 - line goes down */
.bracket-column:nth-child(3) .match-slot:nth-child(1)::before {
  content: '';
  position: absolute;
  top: 50%;
  right: -4rem;
  width: 2px;
  height: 485px; /* 430 (margin-bottom) + 55 */
  background: #888;
  z-index: 1;
}

/* SF Match 2 - line goes up */
.bracket-column:nth-child(3) .match-slot:nth-child(2)::before {
  content: '';
  position: absolute;
  bottom: 50%;
  right: -4rem;
  width: 2px;
  height: 485px;
  background: #888;
  z-index: 1;
}

/* Responsive */
@media (max-width: 1200px) {
  .bracket-grid {
    min-width: 100%;
  }
  
  .bracket-structure {
    flex-wrap: wrap;
    justify-content: center;
  }
  
  .bracket-column {
    margin-bottom: 2rem;
  }
  
  .round-headers {
    flex-wrap: wrap;
    justify-content: center;
  }
}

@media (max-width: 768px) {
  .tournament-bracket {
    padding: 1rem;
  }
  
  .bracket-header h3 {
    font-size: 1.5rem;
  }
  
  .round-header {
    font-size: 1rem;
    min-width: 150px;
  }
  
  .match-slot {
    width: 150px;
  }
  
  .player-name {
    font-size: 0.75rem;
  }
  
  .player-score {
    font-size: 0.875rem;
  }
}
</style>