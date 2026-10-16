import { ApiUser } from '../../domain/models/ApiUser';
import type { User } from '../../domain/models/User';

export function mapApiUserToUser(apiUser: ApiUser): User {
  return {
    id: apiUser.id,
    name: apiUser.name,
    email: apiUser.email,
    city: apiUser.address.city,
    avatarUrl: `https://i.pravatar.cc/150?img=${apiUser.id + 10}`,
  };
}