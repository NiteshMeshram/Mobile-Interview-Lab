import { Image, Pressable, StyleSheet, Text, View } from 'react-native';
import type { User } from '../../domain/models/User';
import { router } from 'expo-router';
import { toggleFavourite } from '../../../favourites/favouritesSlice';
import {
  useAppDispatch,
  useAppSelector,
} from '../../../../store/hooks';
import { useAppTheme } from '../../../../theme/useAppTheme';

import { memo } from 'react';
import { AppColors } from '@/theme/colors';
import GraphQLProfileButton from './GraphQLProfileButton';

type UserCardProps = {
  user: User;
}

function UserCard({ user }: UserCardProps) {
  const dispatch = useAppDispatch();
  const { colors } = useAppTheme();
  const styles = createStyles(colors);

  const isFavourite = useAppSelector((state) =>
    state.favourites.favouriteUserIds.includes(user.id),
  );
  const handlePress = () => {
    router.push({
      pathname: '/users/[id]',
      params: { id: String(user.id) },
    });
  };

  const handleToggleFavourite = () => {
    dispatch(toggleFavourite(user.id));
  };

  const handleGraphQLPress = () => {
    router.push({
      pathname: '/graphql-profile',
      params: { userId: String(user.id) },
    });
  };


  return (
    <View style={styles.cardContainer}>
      <Pressable
        onPress={handlePress}
        accessibilityRole="button"
        accessibilityLabel={`View details for ${user.name}`}
        style={({ pressed }) => [
          styles.card,
          pressed && styles.cardPressed,
        ]}
      >
        <Image source={{ uri: user.avatarUrl }} style={styles.avatar} />

       
        <View style={styles.details}>
          <Text style={styles.name}>{user.name}</Text>
          <Text style={styles.email}>{user.email}</Text>
          <Text style={styles.city}>{user.city}</Text>
        </View>

        <Pressable
          onPress={handleToggleFavourite}
          accessibilityRole="button"
          accessibilityLabel={
            isFavourite
              ? `Remove ${user.name} from favourites`
              : `Add ${user.name} to favourites`
          }
          hitSlop={8}
          style={styles.favouriteButton}
        >
          <Text style={[styles.heart, isFavourite && styles.activeHeart]}>
            {isFavourite ? '♥' : '♡'}
          </Text>
        </Pressable>
      </Pressable>
         <View style={styles.graphqlSection}>
        <GraphQLProfileButton
          userId={user.id}
          userName={user.name}
        />
      </View>

    </View>
  );
}

export default memo(UserCard);

const createStyles = (colors: AppColors) =>
  StyleSheet.create({
    card: {
  flexDirection: 'row',
  alignItems: 'center',
  padding: 16,
  backgroundColor: colors.surface,
},
    avatar: {
      width: 64,
      height: 64,
      borderRadius: 32,
      backgroundColor: colors.toggleBackground,
    },
    details: {
      flex: 1,
      marginLeft: 16,
    },
    name: {
      fontSize: 18,
      fontWeight: '600',
      color: colors.text,
    },
    email: {
      fontSize: 14,
      color: colors.textSecondary,
      marginTop: 4,
    },
    city: {
      fontSize: 13,
      color: colors.textSecondary,
      marginTop: 4,
    },
    cardPressed: {
      opacity: 0.75,
    },
    favouriteButton: {
      padding: 8,
      marginLeft: 8,
    },
    heart: {
      fontSize: 28,
      color: colors.textSecondary,
    },
    activeHeart: {
      color: '#DC2626',
    },

   cardContainer: {
  marginHorizontal: 16,
  marginVertical: 8,
  backgroundColor: colors.surface,
  borderRadius: 12,
  overflow: 'hidden',
  elevation: 2,
},
    graphqlButton: {
      backgroundColor: colors.surface,
      paddingHorizontal: 16,
      paddingVertical: 12,
      alignItems: 'center',
      borderBottomLeftRadius: 12,
      borderBottomRightRadius: 12,
      elevation: 2,
    },
    graphqlButtonText: {
      color: '#2563EB',
      fontSize: 14,
      fontWeight: '600',
    },
    graphqlSection: {
  paddingHorizontal: 16,
  paddingTop: 4,
  paddingBottom: 20,
},
  });