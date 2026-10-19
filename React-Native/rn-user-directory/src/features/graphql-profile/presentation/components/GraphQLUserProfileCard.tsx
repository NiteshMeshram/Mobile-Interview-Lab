import { StyleSheet, Text, View } from 'react-native';
import type { GraphQLUser } from '../../domain/models/GraphQLUser';

interface GraphQLUserProfileCardProps {
  user: GraphQLUser;
}

export function GraphQLUserProfileCard({
  user,
}: GraphQLUserProfileCardProps) {
  return (
    <View style={styles.container}>
      <Text style={styles.name}>{user.name}</Text>
      <Text style={styles.username}>@{user.username}</Text>

      <View style={styles.details}>
        <Text style={styles.label}>Email</Text>
        <Text style={styles.value}>{user.email}</Text>

        <Text style={styles.label}>City</Text>
        <Text style={styles.value}>{user.address.city}</Text>
      </View>

      <Text style={styles.sectionTitle}>Recent Posts</Text>

      {user.posts.data.map((post) => (
        <View key={post.id} style={styles.post}>
          <Text style={styles.postTitle}>{post.title}</Text>
          <Text style={styles.postBody}>{post.body}</Text>
        </View>
      ))}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    backgroundColor: '#FFFFFF',
    borderRadius: 16,
    padding: 20,
    margin: 16,
    elevation: 2,
  },
  name: {
    fontSize: 22,
    fontWeight: '700',
    color: '#172033',
  },
  username: {
    fontSize: 14,
    color: '#64748B',
    marginTop: 4,
  },
  details: {
    marginTop: 20,
  },
  label: {
    fontSize: 12,
    color: '#64748B',
    marginTop: 10,
  },
  value: {
    fontSize: 15,
    color: '#172033',
    marginTop: 3,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: '700',
    color: '#172033',
    marginTop: 24,
    marginBottom: 8,
  },
  post: {
    borderTopWidth: StyleSheet.hairlineWidth,
    borderTopColor: '#E2E8F0',
    paddingVertical: 12,
  },
  postTitle: {
    fontSize: 15,
    fontWeight: '600',
    color: '#172033',
  },
  postBody: {
    fontSize: 14,
    color: '#475569',
    marginTop: 6,
    lineHeight: 20,
  },
});