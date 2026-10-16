const USERS_API_URL = 'https://jsonplaceholder.typicode.com/users';
import type { ApiUser } from '../domain/models/ApiUser';

export async function fetchUsers() {
    const response = await fetch(USERS_API_URL);

    if (!response.ok) {
        throw new Error(`Failed to fetch users: ${response.status}`);
    }

    const users: ApiUser[] = await response.json();

    return users;
}