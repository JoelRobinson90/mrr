import { EuiButton } from '@elastic/eui';
import { EuiButtonPropsForButton } from '@elastic/eui/src/components/button/button';
import React, { useState } from 'react';

export type MedButtonOnceProps = Omit<EuiButtonPropsForButton, 'href'> & {
  loadingText?: string;
};

export const MedButtonOnce: React.FC<MedButtonOnceProps> = ({ onClick, loadingText, children, ...buttonProps }) => {
  const [isLoading, setIsLoading] = useState(false);

  loadingText = loadingText || 'Loading...';

  const onceOnClick: EuiButtonPropsForButton['onClick'] = (event) => {
    if (onClick) {
      onClick(event);
    }
    setIsLoading(true);
  };

  return (
    <EuiButton {...buttonProps} onClick={onceOnClick} isLoading={isLoading}>
      {isLoading ? loadingText : children}
    </EuiButton>
  );
};
