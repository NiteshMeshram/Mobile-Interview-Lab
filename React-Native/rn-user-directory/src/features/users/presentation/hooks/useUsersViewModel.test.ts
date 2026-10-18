
import { act, renderHook, waitFor } from '@testing-library/react-native';
import { fetchUsers } from '../../data/services/userService';
import { loadCachedUsers, setCachedUsers } from '../../data/userCache';
import { useUsersViewModel } from './useUsersViewModel';
import type { ApiUser } from '../../domain/models/ApiUser';

jest.mock('../../data/services/userService', () => ({
  fetchUsers: jest.fn(),
}));

jest.mock('../../data/userCache', () => ({
  loadCachedUsers: jest.fn(),
  setCachedUsers: jest.fn(),
}));

const mockApiUsers: ApiUser[] = [
  {
    id: 1,
    name: 'Leanne Graham',
    username: 'Bret',
    email: 'leanne@example.com',
    address: {
      street: 'Kulas Light',
      suite: 'Apt. 556',
      city: 'Gwenborough',
      zipcode: '92998-3874',
      geo: { lat: '-37.3159', lng: '81.1496' },
    },
    phone: '1-770-736-8031',
    website: 'hildegard.org',
    company: {
      name: 'Romaguera-Crona',
      catchPhrase: 'Multi-layered client-server neural-net',
      bs: 'harness real-time e-markets',
    },
  },
  {
    id: 2,
    name: 'Ervin Howell',
    username: 'Antonette',
    email: 'ervin@example.com',
    address: {
      street: 'Victor Plains',
      suite: 'Suite 879',
      city: 'Wisokyburgh',
      zipcode: '90566-7771',
      geo: { lat: '-43.9509', lng: '-34.4618' },
    },
    phone: '010-692-6593',
    website: 'anastasia.net',
    company: {
      name: 'Deckow-Crist',
      catchPhrase: 'Proactive didactic contingency',
      bs: 'synergize scalable supply-chains',
    },
  },
];

const mockedFetchUsers = jest.mocked(fetchUsers);
const mockedSetCachedUsers = jest.mocked(setCachedUsers);
const mockedLoadCachedUsers = jest.mocked(loadCachedUsers);

describe('useUsersViewModel', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mockedLoadCachedUsers.mockResolvedValue([]);
  });

  it('loads and maps users successfully', async () => {
    mockedFetchUsers.mockResolvedValue(mockApiUsers);

    const { result } = renderHook(() => useUsersViewModel());

    expect(result.current.isLoading).toBe(true);

    await waitFor(() => {
      expect(result.current.isLoading).toBe(false);
    });

    expect(result.current.users).toHaveLength(2);
    expect(result.current.filteredUsers).toHaveLength(2);
    expect(result.current.error).toBeNull();
    expect(mockedSetCachedUsers).toHaveBeenCalledWith(
      result.current.users,
    );
  });

  it('restores cached users before the network request', async () => {
    const cachedUsers = [
      {
        id: 1,
        name: 'Cached User',
        email: 'cached@example.com',
        city: 'Mumbai',
        avatarUrl: 'https://example.com/avatar.png',
      },
    ];

    jest.mocked(loadCachedUsers).mockResolvedValue(cachedUsers);

    // Keep the network request pending so we can inspect the cache first.
    let resolveFetch!: (users: ApiUser[]) => void;

    jest.mocked(fetchUsers).mockImplementation(
      () =>
        new Promise<ApiUser[]>((resolve) => {
          resolveFetch = resolve;
        }),
    );

    const { result } = renderHook(() => useUsersViewModel());

    await waitFor(() => {
      expect(result.current.users).toEqual(cachedUsers);
    });

    expect(loadCachedUsers).toHaveBeenCalledTimes(1);

    // Complete the network request to let the hook finish cleanly.
    await act(async () => {
      resolveFetch(mockApiUsers);
    });

    await waitFor(() => {
      expect(result.current.users).toHaveLength(2);
    });
  });

  it('keeps cached users when the network request fails', async () => {
    const cachedUsers = [
      {
        id: 1,
        name: 'Cached User',
        email: 'cached@example.com',
        city: 'Mumbai',
        avatarUrl: 'https://example.com/avatar.png',
      },
    ];

    jest.mocked(loadCachedUsers).mockResolvedValue(cachedUsers);
    jest.mocked(fetchUsers).mockRejectedValue(
      new Error('Network unavailable'),
    );

    const { result } = renderHook(() => useUsersViewModel());

    await waitFor(() => {
      expect(result.current.error).toBe('Network unavailable');
    });

    expect(result.current.users).toEqual(cachedUsers);
  });


  it('filters users by name, email, and city', async () => {
    mockedFetchUsers.mockResolvedValue(mockApiUsers);

    const { result } = renderHook(() => useUsersViewModel());

    await waitFor(() => {
      expect(result.current.users).toHaveLength(2);
    });

    act(() => {
      result.current.setSearchQuery('ervin');
    });

    expect(result.current.filteredUsers.map((user) => user.id)).toEqual([2]);

    act(() => {
      result.current.setSearchQuery('leanne@example.com');
    });

    expect(result.current.filteredUsers.map((user) => user.id)).toEqual([1]);

    act(() => {
      result.current.setSearchQuery('wisokyburgh');
    });

    expect(result.current.filteredUsers.map((user) => user.id)).toEqual([2]);
  });

  it('filters users by selected city', async () => {
    mockedFetchUsers.mockResolvedValue(mockApiUsers);

    const { result } = renderHook(() => useUsersViewModel());

    await waitFor(() => {
      expect(result.current.users).toHaveLength(2);
    });

    expect(result.current.cities).toEqual([
      'Gwenborough',
      'Wisokyburgh',
    ]);

    act(() => {
      result.current.setSelectedCity('Gwenborough');
    });

    expect(result.current.filteredUsers.map((user) => user.id)).toEqual([1]);

    act(() => {
      result.current.setSelectedCity('');
    });

    expect(result.current.filteredUsers).toHaveLength(2);
  });

  it('exposes an error when loading users fails', async () => {
    mockedFetchUsers.mockRejectedValue(new Error('Network unavailable'));

    const { result } = renderHook(() => useUsersViewModel());

    await waitFor(() => {
      expect(result.current.isLoading).toBe(false);
    });

    expect(result.current.error).toBe('Network unavailable');
    expect(result.current.users).toEqual([]);
  });

  it('retries after a loading failure', async () => {
    mockedFetchUsers
      .mockRejectedValueOnce(new Error('Temporary failure'))
      .mockResolvedValueOnce(mockApiUsers);

    const { result } = renderHook(() => useUsersViewModel());

    await waitFor(() => {
      expect(result.current.error).toBe('Temporary failure');
    });

    await act(async () => {
      await result.current.retryUsers();
    });

    expect(result.current.error).toBeNull();
    expect(result.current.users).toHaveLength(2);
    expect(mockedFetchUsers).toHaveBeenCalledTimes(2);
  });

  it('refreshes users and resets the refreshing state', async () => {
    mockedFetchUsers.mockResolvedValue(mockApiUsers);

    const { result } = renderHook(() => useUsersViewModel());

    await waitFor(() => {
      expect(result.current.isLoading).toBe(false);
    });

    await act(async () => {
      await result.current.refreshUsers();
    });

    expect(mockedFetchUsers).toHaveBeenCalledTimes(2);
    expect(result.current.isRefreshing).toBe(false);
    expect(result.current.users).toHaveLength(2);
  });
});
