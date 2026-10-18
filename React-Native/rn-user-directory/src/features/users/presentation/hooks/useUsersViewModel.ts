import { useEffect, useState, useRef } from 'react';
import type { User } from '../../domain/models/User';
import { fetchUsers } from '../../data/services/userService';
import { mapApiUserToUser } from '../../data/mappers/userMapper';
import { setCachedUsers } from '../../data/userCache';

export function useUsersViewModel() {
  const [users, setUsers] = useState<User[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedCity, setSelectedCity] = useState('');
  const cities = [...new Set(users.map((user) => user.city))].sort();
  const [isRefreshing, setIsRefreshing] = useState(false);

  const requestIdRef = useRef(0);
  const activeControllerRef = useRef<AbortController | null>(null);
  

  const loadUsers = async (isRefresh = false, signal?: AbortSignal) => {
    const requestId = ++requestIdRef.current;

    activeControllerRef.current?.abort();

    const controller = new AbortController();
    activeControllerRef.current = controller;

    const requestSignal = signal ?? controller.signal;

    try {
      if (isRefresh) {
        setIsRefreshing(true);
      } else {
        setIsLoading(true);
      }

      setError(null);

      const apiUsers = await fetchUsers(requestSignal);
      if (requestId !== requestIdRef.current) return;
      const mappedUsers = apiUsers.map(mapApiUserToUser);

      setCachedUsers(mappedUsers);
      setUsers(mappedUsers);
    } catch (err: unknown) {
      if (requestId !== requestIdRef.current) return;
      if (err instanceof Error && err.name === 'AbortError') {
        return;
      }

      const message =
        err instanceof Error ? err.message : 'Something went wrong';
      setError(message);
    } finally {
      if (requestId !== requestIdRef.current) return;

      if (activeControllerRef.current === controller) {
        activeControllerRef.current = null;
      }

      setIsLoading(false);
      setIsRefreshing(false);
    }
  };

  useEffect(() => {
    void loadUsers();

    return () => {
      requestIdRef.current += 1;
      activeControllerRef.current?.abort();
      activeControllerRef.current = null;
    };
  }, []);

  const filteredUsers = users.filter((user) => {
    const query = searchQuery.trim().toLowerCase();

    const matchesSearch =
      user.name.toLowerCase().includes(query) ||
      user.email.toLowerCase().includes(query) ||
      user.city.toLowerCase().includes(query);

    const matchesCity =
      selectedCity === '' || user.city === selectedCity;

    return matchesSearch && matchesCity;
  });

  return {
    users,
    isLoading,
    error,
    searchQuery,
    setSearchQuery,
    filteredUsers,
    cities,
    selectedCity,
    setSelectedCity,
    isRefreshing,
    refreshUsers: () => loadUsers(true),
    retryUsers: () => loadUsers(),
  };
}