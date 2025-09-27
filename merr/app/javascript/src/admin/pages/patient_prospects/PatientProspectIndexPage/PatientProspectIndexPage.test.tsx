// make prospect with demand partner, created_by, notes

import React from 'react';
import { buildDemandPartner, buildUser } from '@/../test_utils/factories';
import { DemandPartner, PatientProspect, User } from '@/common/types';
import { fireEvent, render } from '@testing-library/react';
import { PatientProspectIndexPage } from './PatientProspectIndexPage';

const created_by: User = buildUser();
const demand_partner: DemandPartner = buildDemandPartner();
const prospect: PatientProspect = {
  id: 3,
  diagnosis: ['Diabetes'],
  discharge_end: '2021-05-05',
  discharge_start: '2021-05-01',
  medical_record_number: '8675309',
  notes: 'Patient is hard of hearing',
  preferred_language: 'English',
  zipcode: '33156',
  demand_partner,
  created_by,
  created_at: '2021-05-03T15:29:53.956Z',
};

describe('PatientProspectIndexPage', () => {
  it('displays prospects in a table', async () => {
    const { queryByText, findByText, container } = render(
      <PatientProspectIndexPage
        layout_props={{}}
        patient_prospects={[prospect]}
        pagination={{
          current_page: 1,
          rows_per_page: 25,
          total_pages: 1,
        }}
      />,
    );

    expect(queryByText('5/03/2021')).toBeInTheDocument();
    expect(queryByText(`Patient ID #: ${prospect.medical_record_number}`)).toBeInTheDocument();
    expect(queryByText(created_by.display_name)).toBeInTheDocument();
    expect(queryByText(demand_partner.name)).toBeInTheDocument();

    expect(queryByText(prospect.notes)).not.toBeInTheDocument();
    fireEvent.mouseOver(container.querySelector('.euiToolTipAnchor'));
    expect(await findByText(prospect.notes)).toBeInTheDocument();
  });

  it('shows prospect details when the row is clicked on', async () => {
    const { queryByText, container, baseElement } = render(
      <PatientProspectIndexPage
        layout_props={{}}
        patient_prospects={[prospect]}
        pagination={{
          current_page: 1,
          rows_per_page: 25,
          total_pages: 1,
        }}
      />,
    );

    expect(baseElement.querySelector('.euiFlyout')).not.toBeInTheDocument();
    expect(queryByText('Diabetes')).not.toBeInTheDocument();
    expect(queryByText('English')).not.toBeInTheDocument();
    expect(queryByText('33156')).not.toBeInTheDocument();

    fireEvent.click(container.querySelector('.euiTableRow'));

    expect(baseElement.querySelector('.euiFlyout')).toBeInTheDocument();
    expect(queryByText('Diabetes')).toBeInTheDocument();
    expect(queryByText('English')).toBeInTheDocument();
    expect(queryByText('33156')).toBeInTheDocument();
  });
});
