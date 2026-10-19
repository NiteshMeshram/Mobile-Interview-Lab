import { useQuery } from '@apollo/client/react';
import { GET_USER_PROFILE } from '../../api/queries/userProfileQuery';
import type { GraphQLUser } from '../../domain/models/GraphQLUser';

interface GetUserProfileData {
  user: GraphQLUser | null;
}

interface GetUserProfileVariables {
  userId: string;
}

export function useGraphQLUserProfile(userId?: string) {
  const { data, loading, error, refetch } = useQuery<
    GetUserProfileData,
    GetUserProfileVariables
  >(GET_USER_PROFILE, {
    variables: { userId: userId ?? '' },
    skip: !userId,
  });

  return {
    user: data?.user ?? null,
    loading,
    error,
    refetch,
  };
}