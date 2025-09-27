import { GetCurrentUserQueryResult, useGetCurrentUserQuery, User } from '@/generated/graphql';
import { ApolloProvider } from '@apollo/client';
import React, { createContext, useEffect, useState } from 'react';
import { graphqlClient } from '@/common/graphql/client';
import { FlashToast } from '@/common/components/FlashToast/FlashToast';
import { EuiLoadingContent } from '@elastic/eui';

const allowedClients = ['.force.com'];

export const JwtWebLayout = ({ children }) => {
  const [savedJwt, setSavedJwt] = useState();

  useEffect(() => {
    if (!savedJwt) {
      const message = JSON.stringify({
        type: 'ma:jwtNotFound',
      });
      window.parent.postMessage(message, '*');
    }

    window.addEventListener('message', (e) => {
      if (!allowedClients.some((host) => e.origin.endsWith(host))) {
        return;
      }

      let data;
      try {
        data = JSON.parse(e.data);
      } catch {
        return;
      }

      if (data.type === 'ma:jwt') {
        const token = data.data;

        window.MedArrive = window.MedArrive || {};
        window.MedArrive.activeJwt = token;

        setSavedJwt(token);
      }
    });
  }, []);

  return (
    <div style={{ padding: '1em' }}>
      {savedJwt ? (
        <ApolloProvider client={graphqlClient({ uri: '/graphql_jwt' })}>
          <JwtWebContentWrapper>{children}</JwtWebContentWrapper>
        </ApolloProvider>
      ) : (
        <EuiLoadingContent />
      )}
    </div>
  );
};

type JwtWebContextUser = GetCurrentUserQueryResult['data']['getCurrentUser'];
type JwtWebContextType = {
  user: JwtWebContextUser;
};

export const JwtWebContext = createContext<JwtWebContextType>(null);

const JwtWebContentWrapper: React.FC = ({ children }) => {
  // make a single request first to make sure auth is success and cached
  const { data, loading, error } = useGetCurrentUserQuery();

  if (data?.getCurrentUser) {
    return (
      <JwtWebContext.Provider value={{ user: data?.getCurrentUser }}>
        <FlashToast>{children}</FlashToast>
      </JwtWebContext.Provider>
    );
  }

  return (
    <>
      {data?.getCurrentUser?.id ? children : null}
      {loading && <EuiLoadingContent />}
      {error && `Error: ${error}`}
    </>
  );
};

export const withJwtWebLayout = (component: React.FC): React.FC => ({ children, ...props }) => (
  <JwtWebLayout>{React.createElement(component, props, children)}</JwtWebLayout>
);
