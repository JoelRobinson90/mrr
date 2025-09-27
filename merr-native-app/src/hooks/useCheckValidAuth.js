import { useFocusEffect, useNavigation } from '@react-navigation/native';
import { useCallback, useContext } from 'react';
import { AuthContext } from '../context/auth';
import { clearTokens } from './useOktaAuth';

const useCheckValidAuth = (graphqlError) => {
  const navigation = useNavigation();
  const [, setCurrentUser] = useContext(AuthContext);

  useFocusEffect(useCallback(() => {
    (async () => {
      if (graphqlError?.message?.includes('not authenticated')) {
        clearTokens();
        await setCurrentUser(null);

        navigation.navigate('Home');
      }
    })();
  }, [graphqlError]));
};

export default useCheckValidAuth;
