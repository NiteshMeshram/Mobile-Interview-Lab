import { useEffect, useState } from 'react';
import type { User } from '../../domain/models/User';
import { fetchUsers } from '../../data/userService';
import { mapApiUserToUser } from '../../data/mappers/userMapper';

export function useUsersViewModel() {
  const [users, setUsers] = useState<User[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

 useEffect(() => {
  async function loadUsers() {
    console.log('[UsersViewModel] loadUsers started');

    try {
      setIsLoading(true);
      setError(null);

      console.log('[UsersViewModel] Calling fetchUsers');

      const apiUsers = await fetchUsers();

      console.log('[UsersViewModel] API users received:', apiUsers.length);

      const mappedUsers = apiUsers.map(mapApiUserToUser);

      console.log('[UsersViewModel] Mapped users:', mappedUsers.length);
      console.log(
        '[UsersViewModel] Mapped names:',
        mappedUsers.map((user) => user.name),
      );

      setUsers(mappedUsers);
    } catch (err: unknown) {
      const message =
        err instanceof Error ? err.message : 'Something went wrong';

      console.error('[UsersViewModel] Error:', err);
      setError(message);
    } finally {
      console.log('[UsersViewModel] Loading finished');
      setIsLoading(false);
    }
  }

  loadUsers();
}, []);

  return { users, isLoading, error };
}