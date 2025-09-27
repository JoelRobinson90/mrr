import React, { FC, useEffect, useMemo, useState } from 'react';
import { EuiLoadingSpinner } from '@elastic/eui';
import useInterval from '@/common/hooks/useInterval/useInterval';
import { medFetch } from '@/common/utils/medFetch/medFetch';

type RemotePartialProps = {
  path: string;
  partialProps?: Record<string, unknown>;
  refreshInterval?: number;
};

type RemotePartialResponse = {
  componentName: string;
  componentProps: Record<string, unknown>;
};

export const RemotePartial: React.FC<RemotePartialProps> = ({ path, partialProps = {}, refreshInterval = null }) => {
  const [response, setResponse] = useState<RemotePartialResponse>(null);

  const { componentName, componentProps } = response || {};

  const fetchPath = async () => {
    const response = await medFetch(path);
    if (response.status === 200) {
      const json = (await response.json()) as RemotePartialResponse;
      setResponse(json);
    } else {
      console.error(response);
    }
  };

  useEffect(() => {
    fetchPath();
  }, [path]);

  useInterval(() => {
    fetchPath();
  }, refreshInterval);

  const ComponentTag = useMemo(() => registeredPartials[componentName], [componentName]);

  if (!response) {
    return <Loading />;
  }

  if (componentName && !ComponentTag) {
    console.error(`Error: Partial component not registered: ${componentName}`);
  }

  return <ComponentTag {...componentProps} {...partialProps} />;
};

const Loading = () => (
  <div style={{ margin: '1em' }}>
    <EuiLoadingSpinner size="xl" />
  </div>
);

let registeredPartials = {};

export const registerPartials = (newPartials: { [key: string]: FC }): void => {
  registeredPartials = { ...registeredPartials, ...newPartials };
};
