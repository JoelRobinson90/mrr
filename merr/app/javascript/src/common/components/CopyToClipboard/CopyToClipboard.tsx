import { EuiCopy } from '@elastic/eui';
import React, { FC } from 'react';

export const CopyToClipboard: FC<{ text: string }> = ({ text }) => {
  return (
    <EuiCopy textToCopy={text}>
      {(copy) => (
        <span
          onClick={(e) => {
            copy();
            e.stopPropagation();
          }}
        >
          {text}
        </span>
      )}
    </EuiCopy>
  );
};
