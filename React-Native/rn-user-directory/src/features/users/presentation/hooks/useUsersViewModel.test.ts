
import { UserApiService } from '../../data/services/userService';
import type { ApiUser } from '../../domain/models/ApiUser';
import type { HttpClient } from '@/network/HttpClient';

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

describe('UserApiService', () => {
  let httpClient: jest.Mocked<HttpClient>;
  let service: UserApiService;

  beforeEach(() => {
    httpClient = {
      request: jest.fn(),
      get: jest.fn(),
      post: jest.fn(),
      put: jest.fn(),
      patch: jest.fn(),
      delete: jest.fn(),
    };

    service = new UserApiService(httpClient);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('returns users when the API request succeeds', async () => {
    httpClient.request.mockResolvedValue(mockUsers);

    await expect(service.fetchUsers()).resolves.toEqual(mockUsers);

    expect(httpClient.request).toHaveBeenCalledWith({
      method: 'GET',
      path: '/users',
      signal: undefined,
    });
  });

  it('passes the AbortSignal to the HTTP client', async () => {
    const controller = new AbortController();
    httpClient.request.mockResolvedValue(mockUsers);

    await service.fetchUsers(controller.signal);

    expect(httpClient.request).toHaveBeenCalledWith({
      method: 'GET',
      path: '/users',
      signal: controller.signal,
    });
  });

  it('propagates a network error', async () => {
    httpClient.request.mockRejectedValue(
      new Error('Network request failed'),
    );

    await expect(service.fetchUsers()).rejects.toThrow(
      'Network request failed',
    );
  });

  it('propagates an HTTP error', async () => {
    httpClient.request.mockRejectedValue(
      new Error('HTTP 500: Internal Server Error'),
    );

    await expect(service.fetchUsers()).rejects.toThrow(
      'HTTP 500: Internal Server Error',
    );
  });

  it('propagates an invalid JSON response error', async () => {
    httpClient.request.mockRejectedValue(
      new Error('The server returned invalid JSON.'),
    );

    await expect(service.fetchUsers()).rejects.toThrow(
      'The server returned invalid JSON.',
    );
  });
});
