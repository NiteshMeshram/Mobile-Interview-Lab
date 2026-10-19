export interface GraphQLPost {
  id: string;
  title: string;
  body: string;
}

export interface GraphQLUser {
  id: string;
  name: string;
  username: string;
  email: string;
  address: {
    city: string;
  };
  posts: {
    data: GraphQLPost[];
  };
}