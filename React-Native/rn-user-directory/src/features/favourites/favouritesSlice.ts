
import { createSlice, type PayloadAction } from '@reduxjs/toolkit';

type FavouritesState = {
  favouriteUserIds: number[];
};

const initialState: FavouritesState = {
  favouriteUserIds: [],
};

const favouritesSlice = createSlice({
  name: 'favourites',
  initialState,
  reducers: {
    toggleFavourite: (state, action: PayloadAction<number>) => {
      const userId = action.payload;
      const alreadyFavourite = state.favouriteUserIds.includes(userId);

      if (alreadyFavourite) {
        state.favouriteUserIds = state.favouriteUserIds.filter(
          (id) => id !== userId,
        );
      } else {
        state.favouriteUserIds.push(userId);
      }
    },
  },
});

export const { toggleFavourite } = favouritesSlice.actions;
export default favouritesSlice.reducer;
