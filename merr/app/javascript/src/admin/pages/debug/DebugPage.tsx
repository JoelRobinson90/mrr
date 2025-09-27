import React from 'react';
import {
  EuiPageContent,
  EuiPageContentHeader,
  EuiTitle,
  EuiPageContentBody,
  EuiPageHeader,
  EuiPageHeaderSection,
  EuiPageContentHeaderSection,
  EuiHorizontalRule,
  EuiHorizontalRuleProps,
  EuiText,
} from '@elastic/eui';
import { AdminLayout, AdminLayoutProps } from '@/admin/components/AdminLayout/AdminLayout';

interface DebugPageProps {
  layout_props: AdminLayoutProps;
  [key: string]: any;
}

// export this for testing
const horizontalRuleMargin: EuiHorizontalRuleProps['margin'] = 'm';

export const DebugPage: React.FC<DebugPageProps> = ({ layout_props, ...other_props }) => {
  return (
    <div>
      <AdminLayout {...layout_props}>
        <EuiPageHeader style={{ fontFamily: 'Raleway' }}>
          <EuiPageHeaderSection>
            <EuiTitle size="l">
              <h1>Debug View</h1>
            </EuiTitle>
          </EuiPageHeaderSection>
        </EuiPageHeader>
        <EuiPageContent
          style={{
            backgroundColor: '#ffffff',
            border: 'solid 1px #d3dae6',
            fontFamily: 'Raleway',
          }}
        >
          <EuiPageContentHeader>
            <EuiPageContentHeaderSection>
              <EuiTitle>
                <h2>{layout_props.rails_action}</h2>
              </EuiTitle>
            </EuiPageContentHeaderSection>
          </EuiPageContentHeader>
          <EuiPageContentBody>
            <EuiText size="m" grow={false}>
              <h4>Props:</h4>
              <pre>{JSON.stringify(other_props, null, 2)}</pre>
            </EuiText>
            <EuiHorizontalRule
              margin={horizontalRuleMargin}
              style={{ width: '100%', height: '1px', backgroundColor: '#d3dae6' }}
            />
            <EuiText size="m" grow={false}>
              <h4>Layout props:</h4>
              <pre>{JSON.stringify(layout_props, null, 2)}</pre>
            </EuiText>
          </EuiPageContentBody>
        </EuiPageContent>
      </AdminLayout>
    </div>
  );
};
