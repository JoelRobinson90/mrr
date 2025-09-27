import PropTypes from 'proptypes';
import React, { createContext, useMemo, useState } from 'react';

export const AuthContext = createContext();

export function AuthProvider({ children }) {
  const [currentUser, setCurrentUser] = useState({ isAuthorized: false, accessToken: '' });

  const value = useMemo(() => [currentUser, setCurrentUser], [currentUser]);

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
}

AuthProvider.propTypes = {
  children: PropTypes.any.isRequired,
};
