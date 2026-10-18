
import AsyncStorage from '@react-native-async-storage/async-storage';
import type { User } from '../domain/models/User';

const USERS_CACHE_KEY = '@rn-user-directory/users';

let cachedUsers: User[] = [];

export function getCachedUsers(): User[] {
  return cachedUsers;
}

export function setCachedUsers(users: User[]): void {
  cachedUsers = users;

  void AsyncStorage.setItem(
    USERS_CACHE_KEY,
    JSON.stringify(users),
  ).catch((error: unknown) => {
    // Cache persistence is best-effort; don't fail the API request.
    console.warn('Failed to persist cached users:', error);
  });
}

export async function loadCachedUsers(): Promise<User[]> {
  try {
    const storedUsers = await AsyncStorage.getItem(USERS_CACHE_KEY);

    if (storedUsers) {
      const parsedUsers: unknown = JSON.parse(storedUsers);

      if (Array.isArray(parsedUsers)) {
        cachedUsers = parsedUsers as User[];
      }
    }
  } catch (error) {
    console.warn('Failed to load cached users:', error);
  }

  return cachedUsers;
}

export function getCachedUserById(id: number): User | undefined {
  return cachedUsers.find((user) => user.id === id);
}
