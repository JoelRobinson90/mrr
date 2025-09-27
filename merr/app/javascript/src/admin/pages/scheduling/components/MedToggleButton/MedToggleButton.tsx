import { EuiCard, EuiCheckbox, EuiIcon } from '@elastic/eui';
import React from 'react';
import styled from 'styled-components';

interface MedToggleButtonProps {
  title: string;
  description: string;
  iconName: string;
  isSelected: boolean;
  onClick?: () => void;
  leftBorderColor: string;
  backgroundColor: string;
  isDisabled?: boolean;
}

interface CustomCardProps {
  backgroundColor: string;
  leftBorderColor: string;
}

const CustomCard = styled(EuiCard)<CustomCardProps>`
  &&& {
    max-width: 293px;
    height: 60px;
    padding-top: 10px;
    border: none;
    background-color: ${(props) => props.backgroundColor};
    border-left: 4px solid ${(props) => props.leftBorderColor};
    border-color: ${(props) => props.leftBorderColor} !important;
  }

  .euiCheckbox {
    position: absolute;
    right: 11px;
    top: 12px;
  }

  button {
    display: none;
  }
  .euiCard__title {
    font-size: 16px;
    color: #343741;
    font-weight: bold;
  }
  .euiCard__description {
    font-size: 12px;
    color: #69707d;
    margin: -4px 0 0 !important;
  }
`;

export const MedToggleButton: React.FC<MedToggleButtonProps> = ({
  title,
  description,
  isSelected,
  iconName,
  leftBorderColor,
  backgroundColor,
  onClick,
  isDisabled,
}) => {
  return (
    <CustomCard
      layout="horizontal"
      hasBorder={false}
      icon={<EuiIcon type={iconName} color={leftBorderColor} size="l" />}
      title={
        <>
          {title}
          <EuiCheckbox disabled={isDisabled} id={title} checked={isSelected} onChange={() => {}} />
        </>
      }
      description={description}
      backgroundColor={isSelected ? backgroundColor : '#FFF'}
      leftBorderColor={leftBorderColor}
      selectable={{
        onClick,
        isSelected,
      }}
    />
  );
};
