import { renderHook } from '@testing-library/react-hooks';
import { useFonts } from '@expo-google-fonts/inter';
import useLoadingFonts from '../../src/hooks/useLoadingFonts';

jest.mock('@expo-google-fonts/inter', () => {
  const original = jest.requireActual('@expo-google-fonts/inter');
  return {
    ...original,
    useFonts: jest.fn(),
  };
});

describe('useLoadingFonts', () => {
  it('should return fontsLoaded as true when fonts are loaded', () => {
    useFonts.mockReturnValue([true]);
    const { result } = renderHook(() => useLoadingFonts());
    expect(result.current.fontsLoaded).toBe(true);
  });

  it('should return fontsLoaded as false when fonts are not loaded', () => {
    useFonts.mockReturnValue([false]);
    const { result } = renderHook(() => useLoadingFonts());
    expect(result.current.fontsLoaded).toBe(false);
  });
});
