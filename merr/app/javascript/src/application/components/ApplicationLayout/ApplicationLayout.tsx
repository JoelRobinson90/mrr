import { FlashToast } from '@/common/components/FlashToast/FlashToast';
import React from 'react';
import heartDarkBlue from '@/../images/svg/heartBackgroundDarkBlue.svg';
import heartLightBlue from '@/../images/svg/heartBackgroundLightBlue.svg';
import { DarkBlue, LightBlue } from '@/common/components/MedarriveBackground/MedarriveBackground';
import { ApolloProvider } from '@apollo/client';
import { GraphlClientOptions, graphqlClient } from '@/common/graphql/client';

type ApplicationLayoutProps = {
  graphqlClientOptions?: GraphlClientOptions;
  background?: boolean;
};

export const ApplicationLayout: React.FC<ApplicationLayoutProps> = ({
  children,
  graphqlClientOptions,
  background = true,
}) => {
  return (
    <div className="MedApplicationLayout">
      {background && (
        <>
          <DarkBlue style={{ zIndex: 0 }} src={heartDarkBlue} alt="heartDarkBlue" />
          <LightBlue style={{ zIndex: 0 }} src={heartLightBlue} alt="heartLightBlue" />
        </>
      )}
      <ApolloProvider client={graphqlClient(graphqlClientOptions)}>
        <FlashToast>{children}</FlashToast>
      </ApolloProvider>
    </div>
  );
};

export type ApplicationLayoutConsumerProps = {
  skipApplicationLayout?: boolean;
  graphqlClientOptions?: GraphlClientOptions;
};

export type WithApplicationLayoutProps = ApplicationLayoutConsumerProps & {
  [key: string]: any;
};

export const withApplicationLayout = (component: React.FC): React.FC<WithApplicationLayoutProps> => ({
  skipApplicationLayout,
  graphqlClientOptions,
  children,
  ...props
}) =>
  skipApplicationLayout ? (
    React.createElement(component, props, children)
  ) : (
    <ApplicationLayout graphqlClientOptions={graphqlClientOptions}>
      {React.createElement(component, props, children)}
    </ApplicationLayout>
  );
