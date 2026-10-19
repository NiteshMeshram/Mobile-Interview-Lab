import { gql } from '@apollo/client';

export const GET_USER_PROFILE = gql`
  query GetUserProfile($userId: ID!) {
    user(id: $userId) {
      id
      name
      username
      email
      address {
        city
      }
      posts {
        data {
          id
          title
          body
        }
      }
    }
  }
`;