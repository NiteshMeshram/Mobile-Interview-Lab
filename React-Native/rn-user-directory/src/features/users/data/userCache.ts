
import type { User } from '../domain/models/User';

let cachedUsers: User[] = [];

export function getCachedUsers(): User[] {
  return cachedUsers;
}

export function setCachedUsers(users: User[]): void {
  cachedUsers = users;
}

export function getCachedUserById(id: number): User | undefined {
  return cachedUsers.find((user) => user.id === id);
}
