import { useEffect, useState } from 'react';
import type { User } from '../../domain/models/User';
import { fetchUsers } from '../../data/userService';
import { mapApiUserToUser } from '../../data/mappers/userMapper';

export function useUsersViewModel() {
  const [users, setUsers] = useState<User[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedCity, setSelectedCity] = useState('');
  const cities = [...new Set(users.map((user) => user.city))].sort();
  const [isRefreshing, setIsRefreshing] = useState(false);

  const loadUsers = async (isRefresh = false) => {
    try {
      if (isRefresh) {
        setIsRefreshing(true);
      } else {
        setIsLoading(true);
      }

      setError(null);

      const apiUsers = await fetchUsers();
      const mappedUsers = apiUsers.map(mapApiUserToUser);

      setUsers(mappedUsers);
    } catch (err: unknown) {
      const message =
        err instanceof Error ? err.message : 'Something went wrong';

      setError(message);
    } finally {
      setIsLoading(false);
      setIsRefreshing(false);
    }
  };

  useEffect(() => {
    void loadUsers();
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
};
}