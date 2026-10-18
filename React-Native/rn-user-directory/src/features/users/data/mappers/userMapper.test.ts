
import { mapApiUserToUser } from './userMapper';
import type { ApiUser } from '../../domain/models/ApiUser';

describe('mapApiUserToUser', () => {
  it('maps API user data to the app User model', () => {
    const apiUser: ApiUser = {
      id: 1,
      name: 'Leanne Graham',
      email: 'leanne@example.com',
      address: {
        city: 'Gwenborough',
        street: 'Kulas Light',
        suite: 'Apt. 556',
        zipcode: '92998-3874',
        geo: {
          lat: '-37.3159',
          lng: '81.1496',
        },
      },
      username: 'Bret',
      phone: '1-770-736-8031',
      website: 'hildegard.org',
      company: {
        name: 'Romaguera-Crona',
        catchPhrase: 'Multi-layered client-server neural-net',
        bs: 'harness real-time e-markets',
      },
    };

    const result = mapApiUserToUser(apiUser);

    expect(result).toEqual({
      id: 1,
      name: 'Leanne Graham',
      email: 'leanne@example.com',
      city: 'Gwenborough',
      avatarUrl: 'https://i.pravatar.cc/150?img=11',
    });
  });

  it('generates the avatar URL using the user ID plus 10', () => {
    const apiUser = {
      id: 5,
      name: 'Test User',
      email: 'test@example.com',
      address: {
        city: 'Mumbai',
      },
    } as ApiUser;

    const result = mapApiUserToUser(apiUser);

    expect(result.avatarUrl).toBe(
      'https://i.pravatar.cc/150?img=15',
    );
  });
});
