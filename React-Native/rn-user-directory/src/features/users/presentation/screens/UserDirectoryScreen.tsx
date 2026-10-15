import { useUsersViewModel } from '../hooks/useUsersViewModel';
import { StyleSheet, FlatList, SafeAreaView, Text, View } from 'react-native';
import UserCard from '../components/UserCard';

export default UserDirectoryScreen;

function UserDirectoryScreen() {
    const { users } = useUsersViewModel();
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
  listContent: {
    paddingBottom: 16,
  },
});