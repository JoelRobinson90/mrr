import { withAdminLayout } from '@/admin/components/AdminLayout/AdminLayout';
import { useFlashToast } from '@/common/components/FlashToast/FlashToast';
import { MedTable } from '@/common/components/MedTable/MedTable';
import {
  GetOutreachCampaignsDocument,
  GetOutreachCampaignsQuery,
  useActivateOutreachCampaignMutation,
  useGetOutreachCampaignsQuery,
  useImportOutreachCampaignMutation,
} from '@/generated/graphql';
import React, { useCallback } from 'react';
import { OutreachCampaignsTableMenu, OutreachCampaignsTableMenuAction } from './OutreachCampaignsContextMenu';

type GqlOutreachCampaign = GetOutreachCampaignsQuery['outreachCampaigns'][number];

const OutreachCampaignsIndexPageComponent: React.FC = () => {
  const { data } = useGetOutreachCampaignsQuery();
  const [importFunc] = useImportOutreachCampaignMutation();
  const [activateFunc] = useActivateOutreachCampaignMutation({
    refetchQueries: [
      GetOutreachCampaignsDocument
    ]
  });

  const { addNotice, addAlert } = useFlashToast();

  const onActionSelect = useCallback(
    ({ id, name }: GqlOutreachCampaign) => async (action: OutreachCampaignsTableMenuAction) => {
      switch (action) {
        case OutreachCampaignsTableMenuAction.IMPORT:
          const { importOutreachCampaignContacts } = (await importFunc({ variables: { id } })).data;
          if (importOutreachCampaignContacts.success) {
            addNotice(`Importing contacts for "${name}" in the background`);
          } else {
            addAlert(`Error importing campaign: ${importOutreachCampaignContacts.errors.join(', ')}`);
          }
          break;

        case OutreachCampaignsTableMenuAction.ACTIVATE:
        case OutreachCampaignsTableMenuAction.DEACTIVATE:
          const active = action === OutreachCampaignsTableMenuAction.ACTIVATE;
          const { updateOutreachCampaignActivity } = (await activateFunc({ variables: { id, active }})).data;
          if (updateOutreachCampaignActivity.errors.length) {
            addAlert(`Error activating campaign: ${updateOutreachCampaignActivity.errors.join(', ')}`);
          } else {
            // what to do
            addNotice(`Successfully ${active ? 'activated' : 'deactivated'} "${name}"`);
          }
          
      }
    },
    [],
  );

  if (!data) {
    return <p>Loading...</p>;
  }

  return (
    <>
      <MedTable<GqlOutreachCampaign>
        items={data.outreachCampaigns}
        columns={[
          {
            name: 'Name',
            field: 'name',
          },
          {
            name: 'Active',
            field: 'active',
            render: (active) => (active ? 'yes' : 'no'),
          },
          {
            name: 'Total contacts',
            field: 'contactsTotalCount',
          },
          {
            name: 'Waiting to be sent',
            field: 'contactsCreatedCount',
          },
          {
            name: 'Sent and awaiting status',
            field: 'contactsPendingCount',
          },
          {
            name: 'Total success',
            field: 'contactsSuccessCount',
          },
          {
            name: 'Total failed',
            field: 'contactsFailedCount',
          },
          {
            name: 'Actions',
            render: (campaign: GqlOutreachCampaign) => (
              <>
                <OutreachCampaignsTableMenu campaign={campaign} onSelect={onActionSelect(campaign)} />
              </>
            ),
          },
        ]}
      />
    </>
  );
};

export const OutreachCampaignsIndexPage = withAdminLayout(OutreachCampaignsIndexPageComponent);
