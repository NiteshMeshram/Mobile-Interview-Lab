import { useUsersViewModel } from '../hooks/useUsersViewModel';
import { StyleSheet, FlatList, Text, View, ActivityIndicator, Pressable, TextInput, RefreshControl } from 'react-native';
import UserCard from '../components/UserCard';
import { useAppSelector } from '../../../../store/hooks';
import { useState } from 'react';
import { useAppTheme } from '../../../../theme/useAppTheme';
import type { AppColors } from '../../../../theme/colors';
import { SafeAreaView } from 'react-native-safe-area-context';

export default UserDirectoryScreen;

function UserDirectoryScreen() {
  const { colors } = useAppTheme();
  const styles = createStyles(colors);
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
    retryUsers,
  } = useUsersViewModel();

  const favouriteUserIds = useAppSelector(
    (state) => state.favourites.favouriteUserIds,
  );

  const [showFavouritesOnly, setShowFavouritesOnly] = useState(false);

  const displayedUsers = showFavouritesOnly
    ? filteredUsers.filter((user) => favouriteUserIds.includes(user.id))
    : filteredUsers;

  if (error && displayedUsers.length === 0) {
    return (
      <SafeAreaView style={styles.container}>
        <View style={styles.errorContent}>
          <Text style={styles.errorTitle}>
            Unable to load users
          </Text>

          <Text style={styles.errorMessage}>
            {error}
          </Text>

          <Pressable
            onPress={retryUsers}
            accessibilityRole="button"
            accessibilityLabel="Try loading users again"
            style={styles.retryButton}
          >
            <Text style={styles.retryButtonText}>
              Try Again
            </Text>
          </Pressable>
        </View>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>User Directory</Text>
        <Text style={styles.subtitle}>
          Browse and manage user profiles
        </Text>
      </View>
      <TextInput
        style={styles.searchInput}
        placeholder="Search by name, email, or city..."
        value={searchQuery}
        onChangeText={setSearchQuery}
        autoCapitalize="none"
        clearButtonMode="while-editing"
        accessibilityLabel="Search users"
        accessibilityHint="Enter a name, email address, or city to filter the user list."
        accessibilityRole="search"
        placeholderTextColor={colors.textSecondary}
      />

      <View style={styles.viewToggle}>
        <Pressable
          style={[
            styles.viewToggleButton,
            !showFavouritesOnly && styles.viewToggleButtonSelected,
          ]}
          onPress={() => setShowFavouritesOnly(false)}
          accessibilityRole="button"
          accessibilityState={{ selected: !showFavouritesOnly }}
        >
          <Text
            style={[
              styles.viewToggleText,
              !showFavouritesOnly && styles.viewToggleTextSelected,
            ]}
          >
            All Users
          </Text>
        </Pressable>

        <Pressable
          style={[
            styles.viewToggleButton,
            showFavouritesOnly && styles.viewToggleButtonSelected,
          ]}
          onPress={() => setShowFavouritesOnly(true)}
          accessibilityRole="button"
          accessibilityState={{ selected: showFavouritesOnly }}
        >
          <Text
            style={[
              styles.viewToggleText,
              showFavouritesOnly && styles.viewToggleTextSelected,
            ]}
          >
            Favourites ({favouriteUserIds.length})
          </Text>
        </Pressable>
      </View>

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
              accessibilityRole="button"
              accessibilityLabel={city === 'All' ? 'All cities' : `Filter by ${city}`}
              accessibilityState={{ selected: isSelected }}
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
        data={displayedUsers}
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



const createStyles = (colors: AppColors) =>
  StyleSheet.create({
    centered: {
      flex: 1,
      justifyContent: 'center',
      alignItems: 'center',
      paddingHorizontal: 24,
      paddingVertical: 24,
    },
    errorContainer: {
      padding: 20,
      backgroundColor: colors.errorBackground,
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
      borderColor: colors.border,
      borderRadius: 10,
      paddingHorizontal: 12,
      marginHorizontal: 16,
      marginTop: 12,
      marginBottom: 8,
      backgroundColor: colors.surface,
      color: colors.text,
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
      borderColor: colors.border,
      backgroundColor: colors.surface,
      alignItems: 'center',
      justifyContent: 'center',
    },

    cityChipSelected: {
     backgroundColor: colors.primary,
borderColor: colors.primary,
    },

    cityChipText: {
      color: colors.chipText,
      fontSize: 16,
      lineHeight: 22,
      includeFontPadding: false,
    },

    cityChipTextSelected: {
      color: colors.onPrimary,
      fontWeight: '600',
    },
    viewToggle: {
      flexDirection: 'row',
      marginHorizontal: 16,
      marginTop: 8,
      marginBottom: 8,
      padding: 4,
      borderRadius: 10,
      backgroundColor: '#E5E7EB',
    },

    viewToggleButton: {
      flex: 1,
      paddingVertical: 10,
      alignItems: 'center',
      borderRadius: 8,
    },

    viewToggleButtonSelected: {
      backgroundColor: '#2563EB',
    },

    viewToggleText: {
      color: '#374151',
      fontSize: 14,
      fontWeight: '500',
    },

    viewToggleTextSelected: {
      color: '#FFFFFF',
      fontWeight: '600',
    },
    retryButton: {
      marginTop: 16,
      paddingHorizontal: 24,
      paddingVertical: 12,
      backgroundColor: '#2563EB',
      borderRadius: 8,
    },

    retryButtonText: {
      color: '#FFFFFF',
      fontWeight: '600',
      fontSize: 16,
    },
    errorContent: {
      flex: 1,
      justifyContent: 'center',
      alignItems: 'center',
      paddingHorizontal: 24,
    },
    errorTitle: {
      fontSize: 20,
      fontWeight: '700',
      color: colors.text,
      textAlign: 'center',
    },

    errorMessage: {
      fontSize: 15,
      color: colors.textSecondary,
      textAlign: 'center',
      marginTop: 8,
      lineHeight: 22,
    },
  });