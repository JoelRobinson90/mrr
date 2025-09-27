import { extendTheme } from 'native-base';
import { fontSizes, fonts, fontConfig } from './fonts';

// In Progress / Clocked
const violetDefinition = {
  50: '#F5F3FF',
  100: '#EDE9FE',
  200: '#DDD6FE',
  300: '#C4B5FD',
  400: '#A78BFA',
  500: '#8B5CF6',
  600: '#7C3AED',
  700: '#6D28D9',
  800: '#5B21B6',
  900: '#4C1D95',
};

// scheduled
const emeraldDefinition = {
  50: '#ECFDF5',
  100: '#D1FAE5',
  200: '#A7F3D0',
  300: '#6EE7B7',
  400: '#34D399',
  500: '#10B981',
  600: '#059669',
  700: '#047857',
  800: '#065F46',
  900: '#064E3B',
};

// En Route
const tealDefinition = {
  50: '#F0FDF4',
  100: '#CCFBF1',
  200: '#99F6E4',
  300: '#5EEAD4',
  400: '#2DD4BF',
  500: '#14B8A6',
  600: '#0D9488',
  700: '#0F766E ',
  800: '#115E59',
  900: '#134E4A',
};

// Missed
const yellowDefinition = {
  50: '#FEFCE8',
  100: '#FEF9C3',
  200: '#FEF08A',
  300: '#FDE047',
  400: '#FACC15',
  500: '#EAB308',
  600: '#CA8A04',
  700: '#A16207',
  800: '#854D0E',
  900: '#713F12',
};

const orangeDefinition = {
  50: '#FFF7ED',
  100: '#FFEDD5',
  200: '#FED7AA',
  300: '#FDBA74',
  400: '#FB923C',
  500: '#F97316',
  600: '#EA580C',
  700: '#C2410C',
  800: '#9A3412 ',
  900: '#7C2D12',
};

// Completed
const blueDefinition = {
  50: '#EFF6FF',
  100: '#DBEAFE',
  200: '#BFDBFE',
  300: '#93C5FD',
  400: '#60A5FA',
  500: '#3B82F6',
  600: '#2563EB',
  700: '#1D4ED8',
  800: '#1E40AF',
  900: '#1E3A8A',
};

// Late
const roseDefinition = {
  50: '#FFF1F2',
  100: '#FFE4E6',
  200: '#FECDD3',
  300: '#FDA4AF',
  400: '#FB7185',
  500: '#F43F5E',
  600: '#E11d48',
  700: '#BE123C',
  800: '#9F1239',
  900: '#881337',
};

// Cancelled
const warmGrayDefinition = {
  50: '#FAFAF9',
  100: '#F5F5F4',
  200: '#E7E5E4',
  300: '#D6D3D1',
  400: '#A8A29E',
  500: '#78716C',
  600: '#57534E',
  700: '#44403C',
  800: '#292524',
  900: '#1C1917',
};

// On Site
const cyanDefinition = {
  50: '#ECFEFF',
  100: '#CFFAFE',
  200: '#A5F3FC',
  300: '#67E8F9',
  400: '#22D3EE',
  500: '#06B6D4',
  600: '#0891B2',
  700: '#0E7490',
  800: '#155E75',
  900: '#164E63',
};

const mutedDefinition = {
  50: '#FAFAFA',
  100: '#F5F5F5',
  300: '#D4D4D4',
  500: '#737373',
  600: '#525252',
  700: '#404040',
  800: '#171717',
  900: '#262626',
};

const fuchsiaDefinition = {
  100: '#FAE8FF',
  700: '#A21CAF',
};

const newColorTheme = {
  useSystemColorMode: true,
  violet: {
    ...violetDefinition,
  },
  en_route: {
    ...tealDefinition,
  },
  teal: {
    ...tealDefinition,
  },
  cyan: {
    ...cyanDefinition,
  },
  on_site: {
    ...fuchsiaDefinition,
  },
  confirmed: {
    ...cyanDefinition,
  },
  in_progress: {
    ...violetDefinition,
  },
  clocked: {
    ...violetDefinition,
  },
  scheduled: {
    ...emeraldDefinition,
  },
  emerald: {
    ...emeraldDefinition,
  },
  missed: {
    ...yellowDefinition,
  },
  yellow: {
    ...yellowDefinition,
  },
  orange: {
    ...orangeDefinition,
  },
  blue: {
    ...blueDefinition,
  },
  completed: {
    ...blueDefinition,
  },
  rose: {
    ...roseDefinition,
  },
  late: {
    ...roseDefinition,
  },
  warmGray: {
    ...warmGrayDefinition,
  },
  cancelled: {
    ...warmGrayDefinition,
  },
  canceled: {
    ...warmGrayDefinition,
  },
  muted: {
    ...mutedDefinition,
  },
};

const newComponents = {
  Text: {
    variants: {
      link: ({ colorScheme = 'muted' }) => ({
        textDecorationLine: 'underline',
        fontSize: 'note',
        fontWeight: 400,
        color: `${colorScheme}.800`,
      }),
      title: ({ colorScheme = 'muted' }) => ({
        fontWeight: 700,
        fontSize: 'title',
        color: `${colorScheme}.800`,
      }),
      subTitle: ({ colorScheme = 'muted' }) => ({
        fontWeight: 700,
        fontSize: 'primary',
        color: `${colorScheme}.700`,
      }),
      text: ({ colorScheme = 'muted' }) => ({
        fontWeight: 400,
        fontSize: 'text',
        color: `${colorScheme}.700`,
      }),
      badge: ({ colorScheme }) => ({
        color: `${colorScheme}.700`,
        fontWeight: 500,
        fontSize: 'text',
      }),
      button: ({ colorScheme = 'cyan' }) => ({
        color: `${colorScheme}.600`,
        fontWeight: 500,
      }),
      label: ({ colorScheme }) => ({
        color: `${colorScheme}.500`,
        fontWeight: 500,
        fontSize: 'main',
      }),
      note: ({ colorScheme = 'muted' }) => ({
        color: `${colorScheme}.500`,
        fontWeight: 400,
      }),
    },
  },
  Heading: {
    variants: {
      badge: ({ colorScheme }) => ({
        color: `${colorScheme}.700`,
      }),
    },
  },
  Pressable: {
    variants: {
      visitCard: ({ colorScheme }) => ({
        bg: `${colorScheme}.100`,
        borderColor: `${colorScheme}.700`,
      }),
      visitAction: ({ colorScheme, withoutBorder }) => ({
        borderColor: `${colorScheme}.200`,
        borderBottomWidth: withoutBorder ? 0 : 2,
        py: '16px',
      }),
    },
  },
  Flex: {
    variants: {
      drawer: () => ({
        borderTopLeftRadius: '24px',
        borderTopRightRadius: '24px',
        w: '99%',
        bg: '#FFFFFF',
      }),
    },
  },
  Box: {
    variants: {
      patientInitials: ({ colorScheme }) => ({
        bg: '#FFFFFF',
        borderColor: `${colorScheme}.700`,
        borderRadius: 20,
        height: '40px',
        width: '40px',
        justifyContent: 'center',
        alignItems: 'center',
      }),
      drawer: () => ({
        borderTopLeftRadius: '24px',
        borderTopRightRadius: '24px',
        bg: '#FFFFFF',
      }),
      modal: () => ({
        borderTopLeftRadius: '24px',
        borderTopRightRadius: '24px',
        bg: '#FFFFFF',
      }),
      noteCard: () => ({
        borderWidth: '1px',
        borderColor: '#D4D4D4',
        borderRadius: '8px',
        bg: '#FAFAFA',
        minHeight: '100px',
        padding: '10px',
      }),
    },
  },
  TextArea: {
    variants: {
      noteCard: () => ({
        borderWidth: '1px',
        borderColor: 'muted.300',
        borderRadius: '8px',
        bg: 'muted.50',
        minHeight: '64px',
        padding: '10px',
        placeholderTextColor: 'muted.500',
      }),
    },
  },
  Button: {
    baseStyle: {
      borderRadius: '4px',
      width: 'full',
      _text: {
        fontWeight: 500,
      },
    },
    variants: {
      primary: ({ colorScheme = 'cyan' }) => ({
        bg: `${colorScheme}.500`,
        height: '48px',
        _text: {
          color: 'white',
        },
      }),
      main: ({ colorScheme = 'cyan', outline }) => ({
        bg: outline ? 'transparent' : `${colorScheme}.600`,
        borderWidth: outline ? '1px' : '0',
        borderColor: outline ? `${colorScheme}.600` : 'transparent',
        height: '41px',
        _text: {
          color: outline ? `${colorScheme}.600` : 'white',
        },
      }),
    },
  },
};

export default extendTheme({
  colors: newColorTheme,
  components: newComponents,
  fontSizes,
  fonts,
  fontConfig,
});
