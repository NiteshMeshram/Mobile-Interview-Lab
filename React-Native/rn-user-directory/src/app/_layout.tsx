import { Stack } from 'expo-router';
import { ApolloProvider } from '@apollo/client/react';
import { store, persistor } from '../store/store';
import { Provider } from 'react-redux';
import { apolloClient } from '../features/graphql-profile/api/apolloClient';
import { PersistGate } from 'redux-persist/integration/react';
import { SafeAreaProvider } from 'react-native-safe-area-context';

export default function RootLayout() {
  return (
    <SafeAreaProvider>
      <ApolloProvider client={apolloClient}>
        <Provider store={store}>
          <PersistGate loading={null} persistor={persistor}>
            <Stack screenOptions={{ headerShown: false }} />
          </PersistGate>
        </Provider>
      </ApolloProvider>
    </SafeAreaProvider>
  );
}