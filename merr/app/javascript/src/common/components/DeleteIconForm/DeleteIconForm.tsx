import { EuiButtonIcon } from '@elastic/eui';
import React, { CSSProperties } from 'react';
import styled from 'styled-components';
import { submitSyncForm } from '../SyncForm/SyncForm-utils';

const FormContainerStyled = styled.div`
  && {
    form {
      align-items: center;
      justify-content: center;
      display: flex;
    }
  }
`;

interface Props {
  id: string;
  url: string;
  confirmationMessage: string;
  paddingRight?: number;
  extraStyle?: CSSProperties;
}

export const DeleteIconForm: React.FC<Props> = ({ id, url, confirmationMessage, paddingRight = 17, extraStyle }) => {
  const confirmDelete = () => {
    if (window.confirm(confirmationMessage)) {
      submitSyncForm(url, 'delete', { id });
    }
  };
  return (
    <span style={{ paddingRight }}>
      <FormContainerStyled>
        <EuiButtonIcon
          onClick={confirmDelete}
          data-test-id={`delete-${id}`}
          title="Delete"
          type="button"
          display="base"
          iconType="trash"
          aria-label="Delete"
          style={extraStyle}
        />
      </FormContainerStyled>
    </span>
  );
};
