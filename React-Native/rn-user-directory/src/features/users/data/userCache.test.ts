
import AsyncStorage from '@react-native-async-storage/async-storage';
import type { User } from '../domain/models/User';
import {
  getCachedUserById,
  getCachedUsers,
  loadCachedUsers,
  setCachedUsers,
} from './userCache';

jest.mock('@react-native-async-storage/async-storage', () =>
  require('@react-native-async-storage/async-storage/jest/async-storage-mock'),
);

const mockUsers = [
  {
    id: 1,
    name: 'Leanne Graham',
    email: 'leanne@example.com',
    city: 'Gwenborough',
    avatarUrl: 'https://example.com/avatar.png',
  },
] as User[];

describe('userCache', () => {
  beforeEach(async () => {
    jest.clearAllMocks();
    await AsyncStorage.clear();

    // Reset the module's in-memory cache between tests.
    setCachedUsers([]);
    await AsyncStorage.clear();
  });

  it('persists users when the cache is updated', async () => {
    setCachedUsers(mockUsers);

    // setCachedUsers persists asynchronously.
    await new Promise<void>((resolve) => setTimeout(resolve, 0));

    await expect(
      AsyncStorage.getItem('@rn-user-directory/users'),
    ).resolves.toBe(JSON.stringify(mockUsers));
  });

  it('loads persisted users into the in-memory cache', async () => {
    await AsyncStorage.setItem(
      '@rn-user-directory/users',
      JSON.stringify(mockUsers),
    );

    await expect(loadCachedUsers()).resolves.toEqual(mockUsers);
    expect(getCachedUsers()).toEqual(mockUsers);
    expect(getCachedUserById(1)).toEqual(mockUsers[0]);
  });

  it('returns an empty array when no persisted cache exists', async () => {
    await expect(loadCachedUsers()).resolves.toEqual([]);
  });

  it('does not throw when persisted JSON is malformed', async () => {
    await AsyncStorage.setItem(
      '@rn-user-directory/users',
      '{invalid-json',
    );

    await expect(loadCachedUsers()).resolves.toEqual([]);
  });

  it('returns undefined when a user ID is not cached', () => {
    expect(getCachedUserById(999)).toBeUndefined();
  });
});
