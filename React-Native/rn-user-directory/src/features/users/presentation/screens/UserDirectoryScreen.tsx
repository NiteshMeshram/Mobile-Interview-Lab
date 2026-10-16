import { useUsersViewModel } from '../hooks/useUsersViewModel';
import { StyleSheet, FlatList, SafeAreaView, Text, View, ActivityIndicator } from 'react-native';
import UserCard from '../components/UserCard';

export default UserDirectoryScreen;

function UserDirectoryScreen() {
  const { users, isLoading, error } = useUsersViewModel();

  if (error) {
    return (
      <SafeAreaView style={styles.container}>
        <View style={styles.centered}>
          <Text>Unable to load users.</Text>
          <Text>{error}</Text>
        </View>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>User Directory</Text>
        <Text style={styles.subtitle}>
          My first React Native component
        </Text>
      </View>

      <FlatList
        data={users}
        keyExtractor={(user) => user.id.toString()}
        renderItem={({ item }) => <UserCard user={item} />}
        contentContainerStyle={styles.listContent}
      />
      {isLoading && (
        <View style={styles.centered}>
          <ActivityIndicator size="large" />
          <Text>Loading users...</Text>
        </View>
      )}
    </SafeAreaView>
  );
}



const styles = StyleSheet.create({
  centered: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 24,
  },
  errorContainer: {
    padding: 20,
    backgroundColor: '#FEE2E2',
    borderRadius: 8,
    margin: 16,
  },
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
    paddingBottom: 16,
  },
});