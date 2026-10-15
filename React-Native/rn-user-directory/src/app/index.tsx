import { SafeAreaView, StyleSheet, Text, View } from 'react-native';
import UserCard from '../components/UserCard';

export default function HomeScreen() {
  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>User Directory</Text>
        <Text style={styles.subtitle}>
          My first React Native component
        </Text>
      </View>

      <UserCard
        name="Aarav Sharma"
        email="aarav.sharma@example.com"
        city="Mumbai, India"
        avatarUrl="https://i.pravatar.cc/150?img=12"
      />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F3F4F6',
  },
  header: {
    padding: 20,
  },
  title: {
    fontSize: 28,
    fontWeight: '700',
    color: '#111827',
  },
  subtitle: {
    fontSize: 14,
    color: '#6B7280',
    marginTop: 6,
  },
});