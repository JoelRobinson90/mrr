import { EuiGlobalToastList, htmlIdGenerator } from '@elastic/eui';
import { Toast } from '@elastic/eui/src/components/toast/global_toast_list';
import React, { createContext, useContext, useEffect, useState } from 'react';
import styled from 'styled-components';

export type FlashToastProps = {
  toastLifeTimeMs?: number;
};

const idGenerator = htmlIdGenerator();

const generateToast = (defaults: Partial<Toast>) => (title: string): Toast => ({
  ...defaults,
  id: idGenerator(),
  title,
});
const generateNoticeToast = generateToast({ iconType: 'check', color: 'success' });
const generateAlertToast = generateToast({ iconType: 'help', color: 'danger' });

const StyledEuiGlobalToastList = styled(EuiGlobalToastList)`
  left: 50%;
  top: 0;
  bottom: auto !important;
  transform: translate(-50%, 0);
`;

type FlashToastContextValue = {
  addNotice: (text: string) => void;
  addAlert: (text: string) => void;
};

export const FlashToastContext = createContext<FlashToastContextValue>(null);
export const useFlashToast = () => useContext(FlashToastContext);

export const FlashToast: React.FC<FlashToastProps> = ({ toastLifeTimeMs = 6000, children }) => {
  const [toasts, setToasts] = useState<Toast[]>([]);

  const addToast = (newToast: Toast): void => setToasts((currentToasts) => [...currentToasts, newToast]);
  const removeToast = (removedToast: Toast): void =>
    setToasts((currentToasts) => currentToasts.filter((t) => t.id !== removedToast.id));

  useEffect(() => {
    const { notice, alert } = window.MedArrive?.flash || {};

    if (notice) {
      addToast(generateNoticeToast(notice));
    }
    if (alert) {
      addToast(generateAlertToast(alert));
    }
  }, []);

  const providerValue = {
    addNotice: (text: string) => addToast(generateNoticeToast(text)),
    addAlert: (text: string) => addToast(generateAlertToast(text)),
  };

  return (
    <FlashToastContext.Provider value={providerValue}>
      <StyledEuiGlobalToastList toasts={toasts} dismissToast={removeToast} toastLifeTimeMs={toastLifeTimeMs} />
      {children}
    </FlashToastContext.Provider>
  );
};
