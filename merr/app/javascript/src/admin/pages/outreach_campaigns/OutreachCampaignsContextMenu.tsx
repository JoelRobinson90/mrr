import React, { useMemo, useState } from 'react';
import {
  EuiContextMenu,
  EuiPopover,
  htmlIdGenerator,
  EuiContextMenuPanelDescriptor,
  EuiButtonIcon,
} from '@elastic/eui';
import { OutreachCampaign } from '@/generated/graphql';

export enum OutreachCampaignsTableMenuAction {
  'IMPORT',
  'ACTIVATE',
  'DEACTIVATE',
}

type OutreachCampaignsTableMenuProps = {
  campaign: Partial<OutreachCampaign>;
  onSelect: (selection: OutreachCampaignsTableMenuAction) => void;
};

export const OutreachCampaignsTableMenu: React.FC<OutreachCampaignsTableMenuProps> = ({ campaign, onSelect }) => {
  const [isPopoverOpen, setPopover] = useState(false);

  const contextMenuPopoverId = useMemo(() => htmlIdGenerator()(), []);

  const { active } = campaign;

  const onButtonClick = () => {
    setPopover(!isPopoverOpen);
  };

  const closePopover = () => {
    setPopover(false);
  };

  const panels: EuiContextMenuPanelDescriptor[] = [
    {
      id: 0,
      size: 's',
      items: [
        {
          name: 'Import Kustomer search',
          icon: 'search',
          onClick: () => {
            onSelect(OutreachCampaignsTableMenuAction.IMPORT);
          },
        },
        active
          ? {
              name: 'Deactivate campaign',
              icon: 'pause',
              onClick: () => {
                onSelect(OutreachCampaignsTableMenuAction.DEACTIVATE);
              },
            }
          : {
              name: 'Activate campaign',
              icon: 'playFilled',
              onClick: () => {
                onSelect(OutreachCampaignsTableMenuAction.ACTIVATE);
              },
            },
      ],
    },
  ];

  const button = <EuiButtonIcon onClick={onButtonClick} color="primary" iconType="menu" />;

  return (
    <EuiPopover
      id={contextMenuPopoverId}
      button={button}
      isOpen={isPopoverOpen}
      closePopover={closePopover}
      panelPaddingSize="none"
      anchorPosition="downRight"
    >
      <EuiContextMenu initialPanelId={0} panels={panels} />
    </EuiPopover>
  );
};
