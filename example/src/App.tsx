import { Text, View, StyleSheet, Button } from 'react-native';
import { startCapture } from 'react-native-entrupy';
import { useState } from 'react';

export default function App() {
  const [status, setStatus] = useState<string>('Ready');

  const handleStartCapture = async () => {
    try {
      setStatus('Starting capture...');
      const success = await startCapture('Bags', 'Gucci', 'Handbag', '12345');
      setStatus(`Capture result: ${success}`);
    } catch (e: any) {
      setStatus(`Error: ${e.message}`);
    }
  };

  return (
    <View style={styles.container}>
      <Text style={styles.status}>Status: {status}</Text>
      <Button title="Start Entrupy Capture" onPress={handleStartCapture} />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    padding: 20,
  },
  status: {
    marginBottom: 20,
    fontSize: 16,
    fontWeight: 'bold',
  }
});
