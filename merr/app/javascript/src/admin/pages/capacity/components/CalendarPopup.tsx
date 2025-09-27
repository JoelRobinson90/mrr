import { Popup } from '@mobiscroll/react';
import React, { FC } from 'react';

type CalendarPopupProps = {
  children: any;
  isOpen: boolean;
  visitAnchor: any;
  width?: number;
};

export const CalendarPopup: FC<CalendarPopupProps> = ({ isOpen, width = 350, visitAnchor, children }) => {
  if (!visitAnchor) {
    return null;
  }

  return (
    <Popup
      display="anchored"
      isOpen={isOpen}
      anchor={visitAnchor}
      touchUi={false}
      showOverlay={false}
      contentPadding={false}
      closeOnOverlayClick={false}
      width={width}
      cssClass="md-tooltip"
      scrollLock={false}
    >
      {children}
    </Popup>
  );
};
