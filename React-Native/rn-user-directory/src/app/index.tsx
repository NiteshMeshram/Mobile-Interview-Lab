import { StyleSheet } from 'react-native';
import UserDirectoryScreen from '../features/users/presentation/screens/UserDirectoryScreen';

export default function HomeScreen() {
 return <UserDirectoryScreen />;
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
  listContent: {
    padding: 16,
  },
});