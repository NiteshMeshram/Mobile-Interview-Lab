
import { fetchUsers } from './userService';
import type { ApiUser } from '../../domain/models/ApiUser';

const mockUsers = [
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
      geo: {
        lat: '-37.3159',
        lng: '81.1496',
      },
    },
    phone: '1-770-736-8031',
    website: 'hildegard.org',
    company: {
      name: 'Romaguera-Crona',
      catchPhrase: 'Multi-layered client-server neural-net',
      bs: 'harness real-time e-markets',
    },
  },
] satisfies ApiUser[];

describe('fetchUsers', () => {
  afterEach(() => {
    jest.restoreAllMocks();
  });

  it('returns users when the API request succeeds', async () => {
   jest.spyOn(globalThis, 'fetch').mockResolvedValue({
      ok: true,
      json: jest.fn().mockResolvedValue(mockUsers),
    } as unknown as Response);

    await expect(fetchUsers()).resolves.toEqual(mockUsers);
  });

  it('passes the AbortSignal to fetch', async () => {
    const controller = new AbortController();

    const fetchMock = jest.spyOn(globalThis, 'fetch').mockResolvedValue({
      ok: true,
      json: jest.fn().mockResolvedValue(mockUsers),
    } as unknown as Response);

    await fetchUsers(controller.signal);

    expect(fetchMock).toHaveBeenCalledWith(
      'https://jsonplaceholder.typicode.com/users',
      { signal: controller.signal },
    );
  });

  it('throws a friendly error when the network request fails', async () => {
    jest.spyOn(globalThis, 'fetch').mockRejectedValue(
      new Error('Network request failed'),
    );

    await expect(fetchUsers()).rejects.toThrow(
      'Unable to connect. Please check your internet connection and try again.',
    );
  });

  it('throws an error when the server returns a non-success status', async () => {
    jest.spyOn(globalThis, 'fetch').mockResolvedValue({
      ok: false,
      status: 500,
    } as Response);

    await expect(fetchUsers()).rejects.toThrow(
      'Unable to load users. Server returned status 500. Please try again.',
    );
  });

  it('throws an error when the response JSON cannot be parsed', async () => {
   jest.spyOn(globalThis, 'fetch').mockResolvedValue({
      ok: true,
      json: jest.fn().mockRejectedValue(new Error('Invalid JSON')),
    } as unknown as Response);

    await expect(fetchUsers()).rejects.toThrow(
      'The server returned an invalid response. Please try again later.',
    );
  });
});
