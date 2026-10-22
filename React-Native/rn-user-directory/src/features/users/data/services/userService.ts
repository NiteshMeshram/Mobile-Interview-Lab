
import { HttpClient } from '@/network/HttpClient';
import type { ApiUser } from '../../domain/models/ApiUser';

export class UserApiService {
  constructor(private readonly httpClient: HttpClient) {}

  fetchUsers(signal?: AbortSignal): Promise<ApiUser[]> {
    return this.httpClient.request<ApiUser[]>({
      method: 'GET',
      path: '/users',
      signal,
    });
  }
}