import { ActivityIndicator, Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';
import { useGraphQLUserProfile } from '../features/graphql-profile/presentation/hooks/useGraphQLUserProfile';
import { GraphQLUserProfileCard } from '../features/graphql-profile/presentation/components/GraphQLUserProfileCard';
import { router, useLocalSearchParams} from 'expo-router';
import { SafeAreaView } from 'react-native-safe-area-context';

export default function GraphQLProfileScreen() {
 const params = useLocalSearchParams<{
  userId?: string | string[];
}>();

const selectedUserId = Array.isArray(params.userId)
  ? params.userId[0]
  : params.userId;

const validUserId =
  selectedUserId && /^\d+$/.test(selectedUserId)
    ? selectedUserId
    : undefined;

const { user, loading, error, refetch } =
  useGraphQLUserProfile(validUserId);

  if (loading && !user) {
    return (
      <View style={styles.center}>
        <ActivityIndicator size="large" color="#2563EB" />
        <Text style={styles.message}>Loading GraphQL profile...</Text>
      </View>
    );
  }

  if (error && !user) {
    return (
      <View style={styles.center}>
        <Text style={styles.errorTitle}>Unable to load profile</Text>
        <Text style={styles.message}>{error.message}</Text>
        <Pressable style={styles.button} onPress={() => refetch()}>
          <Text style={styles.buttonText}>Try Again</Text>
        </Pressable>
      </View>
    );
  }

  if (!user) {
    return (
      <View style={styles.center}>
        <Text style={styles.message}>No profile data found.</Text>
        <Pressable style={styles.button} onPress={() => refetch()}>
          <Text style={styles.buttonText}>Retry</Text>
        </Pressable>
      </View>
    );
  }

  return (
     <SafeAreaView style={styles.safeArea} edges={['top', 'bottom']}>
    <ScrollView contentContainerStyle={styles.content}>
      <View style={styles.header}>
        <Pressable
     onPress={() => router.back()}
      accessibilityRole="button"
      accessibilityLabel="Go back to User Directory"
      style={styles.backButton}
    >
      <Text style={styles.backButtonText}>‹  Back to User Directory</Text>
    </Pressable>
        <Text style={styles.title}>GraphQL User Profile</Text>
        <Text style={styles.subtitle}>
          Data fetched using Apollo Client
        </Text>
      </View>

      {error ? (
        <Text style={styles.warning}>
          Refresh failed. Showing previously loaded data.
        </Text>
      ) : null}

      <GraphQLUserProfileCard user={user} />

      <Pressable
        style={styles.button}
        onPress={() => refetch()}
        disabled={loading}
      >
        <Text style={styles.buttonText}>
          {loading ? 'Refreshing...' : 'Refresh Profile'}
        </Text>
      </Pressable>
    </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeArea: {
  flex: 1,
  backgroundColor: '#F1F5F9',
},
  content: {
    flexGrow: 1,
    backgroundColor: '#F1F5F9',
    paddingVertical: 24,
  },
  header: {
    paddingHorizontal: 20,
  },
  title: {
    fontSize: 24,
    fontWeight: '700',
    color: '#172033',
  },
  subtitle: {
    fontSize: 14,
    color: '#64748B',
    marginTop: 6,
  },
  center: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    padding: 24,
    backgroundColor: '#F1F5F9',
  },
  message: {
    fontSize: 14,
    color: '#475569',
    marginTop: 12,
    textAlign: 'center',
  },
  errorTitle: {
    fontSize: 20,
    fontWeight: '700',
    color: '#B91C1C',
  },
  warning: {
    color: '#B45309',
    marginHorizontal: 20,
    marginTop: 16,
  },
  button: {
    backgroundColor: '#2563EB',
    paddingHorizontal: 20,
    paddingVertical: 12,
    borderRadius: 10,
    alignSelf: 'center',
    marginTop: 20,
  },
  buttonText: {
    color: '#FFFFFF',
    fontSize: 15,
    fontWeight: '600',
  },
  backButton: {
  alignSelf: 'flex-start',
  paddingVertical: 10,
  marginBottom: 12,
},

backButtonText: {
  color: '#2563EB',
  fontSize: 16,
  fontWeight: '600',
},
});