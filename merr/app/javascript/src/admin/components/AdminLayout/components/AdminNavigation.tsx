import React from 'react';
import {
  admin_patients_path,
  admin_patient_prospects_path,
  admin_kustomer_patients_new_path,
  admin_appointments_path,
  admin_users_path,
  admin_field_orgs_path,
  admin_demand_partners_path,
  admin_tags_path,
  data_import_new_data_import_path,
  rails_admin_path,
  admin_background_job_results_path,
  alayacare_control_panel_index_path,
  athena_control_panel_index_path,
  admin_capacity_availability_path,
  admin_outreach_campaigns_path,
  flipper_path,
  field_patients_path,
  field_capacity_availability_path,
} from '@/common/routes';
import { EuiImage, EuiNotificationBadge, EuiSideNav, EuiSideNavItemType } from '@elastic/eui';
import logoImg from '@/../images/logos/mark-color.png';
import styled, { css } from 'styled-components';

export const createItem = (name, data = {}) => ({
  name,
  id: name,
  isSelected: false,
  forceOpen: true,
  style: { fontFamily: 'Raleway' },
  ...data,
});

interface NavItemsType extends EuiSideNavItemType<any> {
  items?: Array<EuiSideNavItemType<any>>;
}

const StyledNav = styled(EuiSideNav)<any>`
  ${(props) =>
    props.$isMobile &&
    css`
      overflow: auto;
      height: 85vh;

      h2:first-child {
        display: none;
      }
      .euiSideNav__content {
        opacity: 1;
        overflow: unset;
        visibility: inherit;
        .euiSideNavItem--root.euiSideNavItem--rootIcon > .euiSideNavItem__items {
          padding-bottom: 5rem;
        }
      }
    `}
`;

interface Props {
  prospects_count?: number;
  needs_scheduling_count?: number;
  isMobile?: boolean;
  user_role?: string;
}

const AdminNavigation: React.FC<Props> = ({ prospects_count, needs_scheduling_count, user_role, isMobile = false }) => {
  const adminItems: NavItemsType[] = [
    createItem('MedArrive Admin', {
      icon: <EuiImage url={logoImg} alt="MedArrive Logo" size={16} style={{ width: 16, height: 16 }} />,
      items: [
        createItem('Patients', {
          items: [
            createItem('All', { href: admin_patients_path() }),
            createItem('Prospects', {
              href: admin_patient_prospects_path(),
              icon: prospects_count && (
                <EuiNotificationBadge style={{ backgroundColor: '#ef0075' }}>{prospects_count}</EuiNotificationBadge>
              ),
            }),
            createItem('Needs Scheduling', {
              href: admin_patients_path({ status: 'Referred: Needs Scheduling' }),
              icon: needs_scheduling_count && (
                <EuiNotificationBadge style={{ backgroundColor: '#ef0075' }}>
                  {needs_scheduling_count}
                </EuiNotificationBadge>
              ),
            }),
            createItem('Needs Region', { href: admin_kustomer_patients_new_path() }),
          ],
        }),
        createItem('Appointments', { href: admin_appointments_path() }),
        createItem('Organizations', {
          items: [
            createItem('Field Organizations', { href: admin_field_orgs_path() }),
            createItem('Demand Partners', { href: admin_demand_partners_path() }),
          ],
        }),
        createItem('Tags', {
          items: [
            createItem('Appointment Tags', { href: admin_tags_path({ group: 'Appointment' }) }),
            createItem('Patient Tags', { href: admin_tags_path({ group: 'Patient' }) }),
          ],
        }),
        createItem('Equipment'),
        createItem('Settings'),
        createItem('Background Jobs', { href: admin_background_job_results_path() }),
        createItem('Schedule', { href: admin_capacity_availability_path() }),
        createItem('Super Admin', {
          items: [
            createItem('Data Import', { href: data_import_new_data_import_path() }),
            createItem('AlayaCare Control Panel', { href: alayacare_control_panel_index_path() }),
            createItem('Athena Control Panel', { href: athena_control_panel_index_path() }),
            createItem('Outreach Campaigns', { href: admin_outreach_campaigns_path() }),
            createItem('Database', { href: rails_admin_path() }),
            createItem('Feature Flags', { href: flipper_path() }),
          ],
        }),
      ],
    }),
  ];

  const customerSupportItems: NavItemsType[] = [
    createItem('Customer Support', {
      icon: <EuiImage url={logoImg} alt="MedArrive Logo" size={16} style={{ width: 16, height: 16 }} />,
      items: [
        createItem('Patients', {
          items: [createItem('All', { href: admin_patients_path() })],
        }),
        createItem('Schedule', { href: admin_capacity_availability_path() }),
      ],
    }),
  ];

  const fieldWorkItems: NavItemsType[] = [
    createItem('Field Work', {
      icon: <EuiImage url={logoImg} alt="MedArrive Logo" size={16} style={{ width: 16, height: 16 }} />,
      items: [
        createItem('Patients', {
          items: [createItem('All', { href: field_patients_path() })],
        }),
        createItem('Schedule', { href: field_capacity_availability_path() }),
      ],
    }),
  ];

  const sideNavItems = () => {
    if (user_role === 'MedarriveCustomerSupport' || user_role === 'MedarriveClinicalOperation') {
      return customerSupportItems;
    }

    if (user_role === 'FieldProvider') {
      return fieldWorkItems;
    }

    if (user_role === 'MedarriveAdmin') {
      return adminItems;
    }
  };

  return <StyledNav $isMobile={isMobile} items={sideNavItems()} />;
};

export default AdminNavigation;
