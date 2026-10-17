
import { useEffect, useState } from 'react';
import {
  ActivityIndicator,
  Image,
  Pressable,
  StyleSheet,
  Text,
  View,
} from 'react-native';
import { Stack, useLocalSearchParams, useRouter } from 'expo-router';

import type { User } from '../../features/users/domain/models/User';
import { fetchUsers } from '../../features/users/data/userService';
import { mapApiUserToUser } from '../../features/users/data/mappers/userMapper';

import {
  getCachedUserById,
  setCachedUsers,
} from '../../features/users/data/userCache';

export default function UserDetailsScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const router = useRouter();

  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let isActive = true;
/*
    async function loadUser() {
      try {
        setIsLoading(true);
        setError(null);

        const apiUsers = await fetchUsers();
        const selectedUser = apiUsers.find(
          (apiUser) => String(apiUser.id) === id,
        );

        if (!selectedUser) {
          throw new Error('User not found.');
        }

        if (isActive) {
          setUser(mapApiUserToUser(selectedUser));
        }
      } catch {
        if (isActive) {
          setError('Unable to load user details. Please try again.');
        }
      } finally {
        if (isActive) {
          setIsLoading(false);
        }
      }
    }
    */
    



async function loadUser() {
  try {
    setIsLoading(true);
    setError(null);

    const userId = Number(id);

    if (!Number.isInteger(userId) || userId <= 0) {
      throw new Error('Invalid user ID.');
    }

    const cachedUser = getCachedUserById(userId);

    if (cachedUser) {
      if (isActive) {
        setUser(cachedUser);
      }
      return;
    }

    const apiUsers = await fetchUsers();
    const mappedUsers = apiUsers.map(mapApiUserToUser);

    setCachedUsers(mappedUsers);

    const selectedUser = mappedUsers.find(
      (item) => item.id === userId,
    );

    if (!selectedUser) {
      throw new Error('User not found.');
    }

    if (isActive) {
      setUser(selectedUser);
    }
  } catch {
    if (isActive) {
      setError('Unable to load user details. Please try again.');
    }
  } finally {
    if (isActive) {
      setIsLoading(false);
    }
  }
}


    void loadUser();

    return () => {
      isActive = false;
    };
  }, [id]);

  return (
    <View style={styles.container}>
      <Stack.Screen options={{ title: 'User Details', headerShown: false }} />

      <Pressable
        onPress={() => router.back()}
        accessibilityRole="button"
        accessibilityLabel="Go back to user directory"
        style={styles.backButton}
      >
        <Text style={styles.backText}>← Back to Directory</Text>
      </Pressable>

      {isLoading ? (
        <ActivityIndicator size="large" />
      ) : error ? (
        <Text style={styles.message}>{error}</Text>
      ) : user ? (
        <View style={styles.profile}>
          <Image source={{ uri: user.avatarUrl }} style={styles.avatar} />
          <Text style={styles.name}>{user.name}</Text>
          <Text style={styles.label}>Email</Text>
          <Text style={styles.value}>{user.email}</Text>
          <Text style={styles.label}>City</Text>
          <Text style={styles.value}>{user.city}</Text>
          <Text style={styles.label}>User ID</Text>
          <Text style={styles.value}>{user.id}</Text>
        </View>
      ) : null}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 24,
    paddingTop: 60,
    backgroundColor: '#F9FAFB',
  },
  backButton: {
    alignSelf: 'flex-start',
    marginBottom: 32,
    paddingVertical: 8,
  },
  backText: {
    fontSize: 16,
    color: '#2563EB',
    fontWeight: '600',
  },
  profile: {
    alignItems: 'center',
    padding: 24,
    backgroundColor: '#FFFFFF',
    borderRadius: 16,
    elevation: 2,
  },
  avatar: {
    width: 110,
    height: 110,
    borderRadius: 55,
    backgroundColor: '#E5E7EB',
    marginBottom: 16,
  },
  name: {
    fontSize: 24,
    fontWeight: '700',
    color: '#111827',
    textAlign: 'center',
    marginBottom: 24,
  },
  label: {
    alignSelf: 'stretch',
    fontSize: 13,
    color: '#6B7280',
    marginTop: 12,
  },
  value: {
    alignSelf: 'stretch',
    fontSize: 16,
    color: '#111827',
    marginTop: 4,
  },
  message: {
    fontSize: 16,
    color: '#B91C1C',
  },
});
