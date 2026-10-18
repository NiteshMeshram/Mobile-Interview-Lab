
import { useColorScheme } from 'react-native';
import { darkColors, lightColors } from './colors';

export function useAppTheme() {
  const colorScheme = useColorScheme();

  return {
    colors: colorScheme === 'dark' ? darkColors : lightColors,
    isDark: colorScheme === 'dark',
  };
}
