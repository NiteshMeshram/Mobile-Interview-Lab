
import { Pressable, StyleSheet, Text } from 'react-native';
import { router } from 'expo-router';

type GraphQLProfileButtonProps = {
  userId: string | number;
  userName: string;
};

export default function GraphQLProfileButton({
  userId,
  userName,
}: GraphQLProfileButtonProps) {
  const handlePress = () => {
    router.push({
      pathname: '/graphql-profile',
      params: { userId: String(userId) },
    });
  };

  return (
    <Pressable
      onPress={handlePress}
      accessibilityRole="button"
      accessibilityLabel={`View GraphQL profile for ${userName}`}
      style={({ pressed }) => [
        styles.button,
        pressed && styles.buttonPressed,
      ]}
    >
      <Text style={styles.buttonText}>
        View GraphQL Profile →
      </Text>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  button: {
  backgroundColor: '#2563EB',
  paddingHorizontal: 16,
  paddingVertical: 12,
  alignItems: 'center',
  borderRadius: 8,
  marginHorizontal: 16,
},
  buttonPressed: {
    opacity: 0.75,
  },
  buttonText: {
    color: '#FFFFFF',
    fontSize: 14,
    fontWeight: '600',
  },
});
