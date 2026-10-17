import { useUsersViewModel } from '../hooks/useUsersViewModel';
import { StyleSheet, FlatList, SafeAreaView, Text, View, ActivityIndicator, Pressable } from 'react-native';
import { TextInput } from 'react-native';
import UserCard from '../components/UserCard';
import { RefreshControl } from 'react-native';
export default UserDirectoryScreen;

function UserDirectoryScreen() {
  const {
    isLoading,
    error,
    searchQuery,
    setSearchQuery,
    filteredUsers,
    cities,
    selectedCity,
    setSelectedCity,
    isRefreshing,
    refreshUsers,
  } = useUsersViewModel();

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
      <TextInput
        style={styles.searchInput}
        placeholder="Search by name, email, or city..."
        value={searchQuery}
        onChangeText={setSearchQuery}
        autoCapitalize="none"
        clearButtonMode="while-editing"
      />

      {console.log('[CityFilter] cities:', cities)}
      {console.log('[CityFilter] selectedCity:', selectedCity)}

      <FlatList
        horizontal
        data={['All', ...cities]}
        keyExtractor={(city) => city}
        showsHorizontalScrollIndicator={false}
        style={styles.cityFilterContainer}
        contentContainerStyle={styles.cityFilterList}
        renderItem={({ item: city }) => {
          const isSelected =
            city === 'All' ? selectedCity === '' : selectedCity === city;

          return (
            <Pressable
              style={[
                styles.cityChip,
                isSelected && styles.cityChipSelected,
              ]}
              onPress={() => setSelectedCity(city === 'All' ? '' : city)}
            >
              <Text
                style={[
                  styles.cityChipText,
                  isSelected && styles.cityChipTextSelected,
                ]}
              >
                {city}
              </Text>
            </Pressable>
          );
        }}
      />

      <FlatList
        data={filteredUsers}
        keyExtractor={(user) => user.id.toString()}
        renderItem={({ item }) => <UserCard user={item} />}
        contentContainerStyle={styles.listContent}
        refreshControl={
          <RefreshControl
            refreshing={isRefreshing}
            onRefresh={refreshUsers}
          />
        }
        ListEmptyComponent={
          !isLoading ? (
            <View style={styles.centered}>
              <Text>No users found.</Text>
            </View>
          ) : null
        }
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
  searchInput: {
    height: 48,
    borderWidth: 1,
    borderColor: '#D1D5DB',
    borderRadius: 10,
    paddingHorizontal: 12,
    marginHorizontal: 16,
    marginTop: 12,
    marginBottom: 8,
    backgroundColor: '#FFFFFF',
    color: '#111827',
  },
  cityFilterContainer: {
    flexGrow: 0,
    flexShrink: 0,
    height: 56,
    marginBottom: 8,
  },

  cityFilterList: {
    paddingHorizontal: 16,
    alignItems: 'center',
    gap: 8,
  },

  cityChip: {
    minHeight: 44,
    paddingHorizontal: 16,
    paddingVertical: 10,
    borderRadius: 24,
    borderWidth: 1,
    borderColor: '#D1D5DB',
    backgroundColor: '#FFFFFF',
    alignItems: 'center',
    justifyContent: 'center',
  },

  cityChipSelected: {
    backgroundColor: '#2563EB',
    borderColor: '#2563EB',
  },

  cityChipText: {
    color: '#374151',
    fontSize: 16,
    lineHeight: 22,
    includeFontPadding: false,
  },

  cityChipTextSelected: {
    color: '#FFFFFF',
    fontWeight: '600',
  },
});