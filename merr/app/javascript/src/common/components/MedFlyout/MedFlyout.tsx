import React, { ReactNode } from 'react';
import {
  EuiButton,
  EuiButtonEmpty,
  EuiButtonEmptyProps,
  EuiButtonProps,
  EuiFlexGroup,
  EuiFlexItem,
  EuiFlyout,
  EuiFlyoutBody,
  EuiFlyoutFooter,
  EuiFlyoutHeader,
  EuiFlyoutProps,
  EuiTitle,
} from '@elastic/eui';

interface Props extends EuiFlyoutProps {
  title: string;
  show: boolean;
  onClose: () => void;
  cancelButton?: EuiButtonEmptyProps & { text: string };
  confirmButton?: EuiButtonProps & { text: string; onClick: () => void; type?: any; form?: any };
  showFooter?: boolean;
  dataTestId?: string;
  subText?: ReactNode | string;
}

export const MedFlyout: React.FC<Props> = ({
  title,
  children,
  show,
  cancelButton,
  confirmButton,
  showFooter,
  onClose,
  size = 's',
  dataTestId,
  subText,
}) => {
  if (!show) return null;
  const { text: cancelText, ...cancelButtonProps } = cancelButton || { text: null };
  const { text: confirmText, ...confirmButtonProps } = confirmButton || { text: null };
  return (
    <EuiFlyout ownFocus onClose={onClose} size={size} data-testid={dataTestId}>
      <EuiFlyoutHeader hasBorder>
        <EuiTitle>
          <h2>{title}</h2>
        </EuiTitle>
        {subText}
      </EuiFlyoutHeader>
      <EuiFlyoutBody>{children}</EuiFlyoutBody>
      {showFooter && (
        <EuiFlyoutFooter>
          <EuiFlexGroup justifyContent="spaceBetween">
            <EuiFlexItem grow={false}>
              <EuiButtonEmpty {...cancelButtonProps}>{cancelText}</EuiButtonEmpty>
            </EuiFlexItem>
            {confirmText && (
              <EuiFlexItem grow={false}>
                <EuiButton {...confirmButtonProps}>{confirmText}</EuiButton>
              </EuiFlexItem>
            )}
          </EuiFlexGroup>
        </EuiFlyoutFooter>
      )}
    </EuiFlyout>
  );
};
