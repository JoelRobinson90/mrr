import React from 'react';
import {
  EuiFlexGroup,
  EuiFlexItem,
  EuiPageContent,
  EuiPageContentBody,
  EuiSpacer,
  EuiText,
  EuiTitle,
} from '@elastic/eui';

import { AdminLayout, AdminPageProps } from '@/admin/components/AdminLayout/AdminLayout';
import { PaginationFooter } from '@/common/components/PaginationFooter/PaginationFooter';
import { AppointmentAccordion } from '@/admin/components/AppointmentAccordion/AppointmentAccordion';
import { Appointment, DemandPartner } from '@/common/types';
import { SearchWithFilters } from '@/admin/components/filters/SearchWithFilters/SearchWithFilters';
import { getUpdatedQueryPath } from '@/common/utils/queries/queries';
import { PaginationParams, usePagination } from '@/common/hooks/usePagination/usePagination';
import { TotalBadges } from '@/common/components/TotalBadges/TotalBadges';

interface AppointmentIndexPageProps extends AdminPageProps {
  appointments: Appointment[];
  pagination: PaginationParams;
  statuses: string[];
  available_tags: string[];
  demand_partners: DemandPartner[];
  filters: {
    status: string;
    tag: string;
    demand_partner: string;
    start: string;
    end: string;
  };
  query: string;
  appointments_count: number;
}

export const AppointmentIndexPage: React.FC<AppointmentIndexPageProps> = ({
  layout_props,
  pagination,
  appointments,
  statuses,
  available_tags,
  demand_partners,
  filters,
  query,
  appointments_count,
}) => {
  const paginationProps = usePagination(pagination);

  const onSearch = (query: string): void => {
    location.assign(getUpdatedQueryPath({ s: query }));
  };

  const options = {
    start_date: true,
    statuses: statuses.map((s) => ({
      label: s,
      value: s,
    })),
    available_tags: available_tags.map((s) => ({
      label: s,
      value: s,
    })),
    demand_partners: demand_partners.map((d) => ({
      label: d.name,
      value: `${d.id}`,
    })),
  };

  const totalBadges = [
    {
      title: 'total',
      value: appointments_count,
      color: '#0820c5',
    },
  ];

  return (
    <div>
      <AdminLayout {...layout_props}>
        <EuiPageContent>
          <EuiFlexGroup alignItems="center" gutterSize="xl" style={{ marginBottom: 20 }} wrap responsive={false}>
            <EuiFlexItem grow={false}>
              <EuiTitle size="l">
                <h1>Appointments</h1>
              </EuiTitle>
            </EuiFlexItem>
            <TotalBadges data={totalBadges} />
          </EuiFlexGroup>
          <SearchWithFilters options={options} filters={filters} query={query} onSearch={onSearch} />
          <EuiText size="s" color="subdued">
            {
              'Search prefixes of: Appt ID, address, first name, last name, Patient ID, DOB (must be YYYY-MM-DD), or phone (must be +15551112222).'
            }
          </EuiText>
          <EuiSpacer size="xl" />

          <EuiPageContentBody>
            {/* List of appointments */}
            {appointments.map((appointment) => {
              return (
                <a key={appointment.id} href={`/admin/appointments/${appointment.id}`}>
                  <AppointmentAccordion appointment={appointment} disableAccordion="closed" />
                </a>
              );
            })}
            <PaginationFooter {...paginationProps} />
          </EuiPageContentBody>
        </EuiPageContent>
      </AdminLayout>
    </div>
  );
};
