import { Stack } from 'expo-router';
import { store } from '../store/store';
import { Provider } from 'react-redux';
import { PersistGate } from 'redux-persist/integration/react';
import { persistor } from '../store/store';

export default function RootLayout() {
  return (
     <Provider store={store}>
       <PersistGate loading={null} persistor={persistor}>
        <Stack screenOptions={{ headerShown: false }} />
       </PersistGate>
     </Provider>
  );
}