import { Stack } from 'expo-router';
import { store } from '../store/store';
import { Provider } from 'react-redux';
import { PersistGate } from 'redux-persist/integration/react';
import { persistor } from '../store/store';
import { SafeAreaProvider } from 'react-native-safe-area-context';

export default function RootLayout() {
  return (
    <SafeAreaProvider>
     <Provider store={store}>
       <PersistGate loading={null} persistor={persistor}>
        <Stack screenOptions={{ headerShown: false }} />
       </PersistGate>
     </Provider>
    </SafeAreaProvider>
  );
}