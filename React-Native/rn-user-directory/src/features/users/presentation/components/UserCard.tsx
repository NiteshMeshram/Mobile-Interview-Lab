import { Image, Pressable, StyleSheet, Text, View } from 'react-native';
import type { User } from '../../domain/models/User';
import { router } from 'expo-router';

type UserCardProps = {
  user: User;
}

export default function UserCard({ user }: UserCardProps) {
  const handlePress = () => {
    console.log('Opening user details:', user.id);
    router.push({
      pathname: '/users/[id]',
      params: { id: String(user.id) },
    });
  };

  return (
    <Pressable
      onPress={handlePress}
      accessibilityRole="button"
      accessibilityLabel={`View details for ${user.name}`}
      style={({ pressed }) => [
        styles.card,
        pressed && styles.cardPressed,
      ]}
    >
      {/* <View style={styles.card}> */}
      <Image source={{ uri: user.avatarUrl }} style={styles.avatar} />

      <View style={styles.details}>
        <Text style={styles.name}>{user.name}</Text>
        <Text style={styles.email}>{user.email}</Text>
        <Text style={styles.city}>{user.city}</Text>
      </View>
      {/* </View> */}


    </Pressable>

  );
}

const styles = StyleSheet.create({
  card: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 16,
    marginHorizontal: 16,
    marginVertical: 8,
    backgroundColor: '#FFFFFF',
    borderRadius: 12,
    elevation: 2,
  },
  avatar: {
    width: 64,
    height: 64,
    borderRadius: 32,
    backgroundColor: '#E5E7EB',
  },
  details: {
    flex: 1,
    marginLeft: 16,
  },
  name: {
    fontSize: 18,
    fontWeight: '600',
    color: '#111827',
  },
  email: {
    fontSize: 14,
    color: '#4B5563',
    marginTop: 4,
  },
  city: {
    fontSize: 13,
    color: '#6B7280',
    marginTop: 4,
  },
  cardPressed: {
    opacity: 0.75,
  },
});