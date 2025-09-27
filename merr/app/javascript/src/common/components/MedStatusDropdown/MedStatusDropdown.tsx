import React, { useState } from 'react';
import styled from 'styled-components';

import { MedTextField } from '@/common/components/forms';
import { STATUS_COLOR_MAP } from '@/common/components/MedBadge/MedBadge';
import { EuiContextMenu, EuiPopover } from '@elastic/eui';
import { SyncForm } from '@/common/components/SyncForm/SyncForm';
import { useForm } from 'react-hook-form';

const InputHidden = styled(MedTextField)`
  display: none;
`;

export const StatusStyled = styled.button`
  display: flex;
  cursor: pointer;
  padding: 12px;
  text-align: left;
  ${(props: { button?: boolean }) =>
    props.button
      ? `
        border: 1px solid #d3dae6;
        box-shadow: 0 2px 2px -1px rgb(152 162 179 / 30%), 0 1px 5px -2px rgb(152 162 179 / 30%);
      `
      : ''}
  &::before {
    content: '';
    display: block;
    width: 8px;
    height: 8px;
    border-radius: 8px;
    background-color: ${(props) => props.color};
    margin: auto 15px auto 6px;
  }
`;

export type MedStatusDropdownProps = {
  status: string;
  statuses: string[];
  url?: string;
  defaultValues?: {
    status: string;
  };
  name?: string;
};

export const MedStatusDropdown: React.FC<MedStatusDropdownProps> = ({ status, statuses, url, defaultValues, name }) => {
  const [isPopoverOpen, setPopover] = useState(false);
  const [currentStatus, setCurrentStatus] = useState(defaultValues.status);

  const onButtonClick = () => {
    setPopover(!isPopoverOpen);
  };

  const closePopover = () => {
    setPopover(false);
  };

  const form = useForm({
    defaultValues,
  });

  const panels: {
    id: number;
    content: JSX.Element;
  }[] = [
    {
      id: 0,
      content: (
        <SyncForm form={form} url={url} method="put">
          <InputHidden data-testid="status-input-test" name={name} value={currentStatus} readOnly />
          <div style={{ padding: 8 }}>
            {statuses.map((s) => (
              <StatusStyled
                key={s}
                color={STATUS_COLOR_MAP[s]}
                onClick={() => {
                  setCurrentStatus(s);
                }}
                type="submit"
              >
                {s}
              </StatusStyled>
            ))}
          </div>
        </SyncForm>
      ),
    },
  ];

  const button = (
    <StatusStyled button color={STATUS_COLOR_MAP[status]} onClick={onButtonClick} className="statusButton">
      {status || defaultValues.status}
    </StatusStyled>
  );

  return (
    <>
      <EuiPopover
        button={button}
        isOpen={isPopoverOpen}
        closePopover={closePopover}
        panelPaddingSize="none"
        anchorPosition="downRight"
      >
        <EuiContextMenu initialPanelId={0} panels={panels} />
      </EuiPopover>
    </>
  );
};
