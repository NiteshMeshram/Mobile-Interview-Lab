
import { fireEvent, render, screen } from '@testing-library/react-native';
import UserCard from './UserCard';
import { router } from 'expo-router';
import { toggleFavourite } from '../../../favourites/favouritesSlice';
import {
  useAppDispatch,
  useAppSelector,
} from '../../../../store/hooks';

jest.mock('expo-router', () => ({
  router: {
    push: jest.fn(),
  },
}));


jest.mock('../../../favourites/favouritesSlice', () => ({
  toggleFavourite: jest.fn((userId: number) => ({
    type: 'favourites/toggleFavourite',
    payload: userId,
  })),
}));


jest.mock('../../../../store/hooks', () => ({
  useAppDispatch: jest.fn(),
  useAppSelector: jest.fn(),
}));

jest.mock('../../../../theme/useAppTheme', () => ({
  useAppTheme: () => ({
    colors: {
      surface: '#FFFFFF',
      toggleBackground: '#EEEEEE',
      text: '#111111',
      textSecondary: '#666666',
    },
  }),
}));

const mockDispatch = jest.fn();
let mockFavouriteIds: number[] = [];

const mockUser = {
  id: 7,
  name: 'Leanne Graham',
  email: 'leanne@example.com',
  city: 'Gwenborough',
  avatarUrl: 'https://example.com/avatar.png',
};

describe('UserCard', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mockFavouriteIds = [];

    jest.mocked(useAppDispatch).mockReturnValue(
      mockDispatch as never,
    );

    jest.mocked(useAppSelector).mockImplementation(
      ((selector: (state: unknown) => unknown) =>
        selector({
          favourites: {
            favouriteUserIds: mockFavouriteIds,
          },
        })) as never,
    );
  });

  it('renders user information and avatar', () => {
    render(<UserCard user={mockUser} />);

    expect(screen.getByText('Leanne Graham')).toBeTruthy();
    expect(screen.getByText('leanne@example.com')).toBeTruthy();
    expect(screen.getByText('Gwenborough')).toBeTruthy();

    expect(screen.getByLabelText('View details for Leanne Graham'))
      .toBeTruthy();

    expect(screen.getByLabelText('Add Leanne Graham to favourites'))
      .toBeTruthy();
  });

  it('dispatches the favourite action when the favourite button is pressed', () => {
    render(<UserCard user={mockUser} />);

    fireEvent.press(
      screen.getByLabelText('Add Leanne Graham to favourites'),
    );

    expect(mockDispatch).toHaveBeenCalledWith(
      toggleFavourite(7),
    );
  });

  it('shows the remove-favourite label for a favourite user', () => {
    mockFavouriteIds = [7];

    render(<UserCard user={mockUser} />);

    expect(
      screen.getByLabelText('Remove Leanne Graham from favourites'),
    ).toBeTruthy();

    expect(screen.getByText('♥')).toBeTruthy();
  });

  it('navigates to the user details screen when the card is pressed', () => {
    render(<UserCard user={mockUser} />);

    fireEvent.press(
      screen.getByLabelText('View details for Leanne Graham'),
    );

    expect(router.push).toHaveBeenCalledWith({
      pathname: '/users/[id]',
      params: { id: '7' },
    });
  });
});
