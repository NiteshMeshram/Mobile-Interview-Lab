const USERS_API_URL = 'https://jsonplaceholder.typicode.com/users';
import type { ApiUser } from '../domain/models/ApiUser';

// let shouldSimulateInitialFailure = true; // Test retry mechanism by simulating initial failure

export async function fetchUsers(signal?: AbortSignal) {
    let response: Response;

    //     if (shouldSimulateInitialFailure) {
    //     shouldSimulateInitialFailure = false;
    //     throw new Error('Simulated network failure. Please tap Retry.');
    //   }

    try {
        response = await fetch(USERS_API_URL, { signal });
    } catch {
        throw new Error(
            'Unable to connect. Please check your internet connection and try again.',
        );
    }

    if (!response.ok) {
        throw new Error(
            `Unable to load users. Server returned status ${response.status}. Please try again.`,
        );
    }

    let users: ApiUser[];

    try {
        users = (await response.json()) as ApiUser[];
    } catch {
        throw new Error(
            'The server returned an invalid response. Please try again later.',
        );
    }

    return users;
}