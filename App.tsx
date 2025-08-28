// App.tsx
import React, { useState, useEffect } from 'react'
import {
  StyleSheet,
  View,
  Text,
  Alert,
  TextInput,
  TouchableOpacity,
} from 'react-native'
import { StatusBar } from 'expo-status-bar'
import {
  startLiveActivity,
  updateLiveActivity,
  stopLiveActivity,
  isLiveActivityRunning,
  areLiveActivitiesEnabled,
  reloadWidget,
  setWidgetData
} from './modules/activity-controller'


type SetScore = {
  playerOne: string
  playerTwo: string
}

export default function App() {
  const [sets, setSets] = useState<SetScore[]>([
    { playerOne: '0', playerTwo: '0' },
    { playerOne: '0', playerTwo: '0' },
    { playerOne: '0', playerTwo: '0' },
  ])
  const [running, setRunning] = useState(false)

  // Push updates to Live Activity (if running) and always update the Home Screen widget
  useEffect(() => {
    if (running && isLiveActivityRunning()) {
      updateLiveActivity({ setScores: sets }).catch((e) =>
        Alert.alert('Error updating Live Activity', e.message)
      )
    }

    // ⬇️ Keep widget in sync too (doesn't require Live Activity)
    setWidgetData({
      playerOneName: 'Sinner',
      playerTwoName: 'Alcaraz',
      setScores: sets,
    })
      .then(() => reloadWidget())
      .catch(() => {})
  }, [sets, running])

  const onChangeScore = (
    idx: number,
    field: keyof SetScore,
    value: string
  ) => {
    const copy = [...sets]
    copy[idx] = { ...copy[idx], [field]: value }
    setSets(copy)
  }

  const startActivityHandler = async () => {
    if (!areLiveActivitiesEnabled) {
      return Alert.alert('Live Activities not enabled on this device.')
    }
    try {
      await startLiveActivity({
        playerOneName: 'Sinner',
        playerTwoName: 'Alcaraz',
        setScores: sets,
      })
      setRunning(true)

      // ⬇️ Also seed the widget immediately on start
      await setWidgetData({
        playerOneName: 'Sinner',
        playerTwoName: 'Alcaraz',
        setScores: sets,
      })
      await reloadWidget()
    } catch (e: any) {
      Alert.alert('Error starting Live Activity', e.message)
    }
  }

  const stopActivityHandler = async () => {
    if (!running || !isLiveActivityRunning()) return
    try {
      await stopLiveActivity()
      setRunning(false)
    } catch (e: any) {
      Alert.alert('Error stopping Live Activity', e.message)
    }
  }

  return (
    <View style={styles.container}>
      <Text style={styles.title}>🎾 Tennis Live Activity</Text>

      {sets.map((set, idx) => (
        <View key={idx} style={styles.scoreRow}>
          <Text>Set {idx + 1}</Text>
          <TextInput
            style={styles.input}
            keyboardType="number-pad"
            value={set.playerOne}
            onChangeText={(v) => onChangeScore(idx, 'playerOne', v)}
          />
          <Text style={styles.vs}>–</Text>
          <TextInput
            style={styles.input}
            keyboardType="number-pad"
            value={set.playerTwo}
            onChangeText={(v) => onChangeScore(idx, 'playerTwo', v)}
          />
        </View>
      ))}

      <View style={styles.buttons}>
        <TouchableOpacity
          style={[
            styles.controlButton,
            running ? styles.runningButton : styles.startButton,
          ]}
          onPress={running ? undefined : startActivityHandler}
          disabled={running}
        >
          <Text style={styles.controlText}>
            {running ? 'Running…' : 'Start Activity'}
          </Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={[styles.controlButton, styles.stopButton]}
          onPress={stopActivityHandler}
          disabled={!running}
        >
          <Text style={styles.controlText}>Stop Activity</Text>
        </TouchableOpacity>
      </View>

      <StatusBar style="auto" />
    </View>
  )
}

const styles = StyleSheet.create({
  container: { flex: 1, padding: 24, justifyContent: 'center' },
  title: { fontSize: 20, textAlign: 'center', marginBottom: 16 },
  scoreRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 12,
  },
  input: {
    borderWidth: 1,
    borderColor: '#888',
    borderRadius: 4,
    padding: 8,
    width: 50,
    textAlign: 'center',
    marginHorizontal: 8,
  },
  vs: { fontSize: 18 },
  buttons: { flexDirection: 'row', justifyContent: 'space-between', marginTop: 24 },
  controlButton: {
    flex: 1,
    padding: 12,
    borderRadius: 6,
    alignItems: 'center',
    marginHorizontal: 4,
  },
  startButton: { backgroundColor: '#4CAF50' },
  runningButton: { backgroundColor: '#FFC107' },
  stopButton: { backgroundColor: '#F44336' },
  controlText: { color: '#fff', fontWeight: 'bold' },
})
