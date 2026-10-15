import { Image, StyleSheet, Text, View } from 'react-native';

type UserCardProps = {
  name: string;
  email: string;
  city: string;
  avatarUrl: string;
};

export default function UserCard({
  name,
  email,
  city,
  avatarUrl,
}: UserCardProps) {
  return (
    <View style={styles.card}>
      <Image source={{ uri: avatarUrl }} style={styles.avatar} />

      <View style={styles.details}>
        <Text style={styles.name}>{name}</Text>
        <Text style={styles.email}>{email}</Text>
        <Text style={styles.city}>{city}</Text>
      </View>
    </View>
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
});