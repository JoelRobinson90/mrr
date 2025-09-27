import {
  EuiButton,
  EuiFilterGroup,
  EuiFlexGroup,
  EuiFlexItem,
  EuiSpacer,
  EuiText,
  EuiPageContentHeader,
  EuiPageContentHeaderSection,
  EuiTitle,
} from '@elastic/eui';
import React, { useEffect, useMemo, useState } from 'react';
import queryString from 'query-string';
import { keyBy } from 'lodash';

import { AdminLayout, AdminPageProps } from '@/admin/components/AdminLayout/AdminLayout';
import { Patient, DemandPartner } from '@/common/types';
import { InMemoryPatientsTable } from '@/admin/components/PatientsTable/PatientsTable';
import { FilterSelect } from '@/admin/components/FilterSelect/FilterSelect';
import { useSyncForm } from '@/common/hooks/useSyncForm/useSyncForm';
import { admin_kustomer_patients_create_path } from '@/common/routes';
import { yupResolver } from '@hookform/resolvers';
import * as yup from 'yup';
import { MedHiddenField, MedTextField } from '@/common/components/forms';
import { SyncForm } from '@/common/components/SyncForm/SyncForm';

interface KustomerMapSelectionNewPageProps extends AdminPageProps {
  patients: Patient[];
  geojson: GeoJSON.FeatureCollection<GeoJSON.Geometry>;
  demand_partners: DemandPartner[];
  demand_partner_id: number;
}

const kustomerCreatePatientSchema = yup.object().shape({
  title: yup.string().label('Title').required(),
});

export const KustomerMapSelectionNewPage: React.FC<KustomerMapSelectionNewPageProps> = ({
  layout_props,
  patients,
  geojson,
  demand_partners,
  demand_partner_id,
}) => {
  const patientsMap = useMemo(() => keyBy(patients, 'id'), []);

  const [selectedPoints, setSelectedPoints] = useState([]);
  const selectedPatients = useMemo(() => selectedPoints.map((point) => patientsMap[point]), [selectedPoints.join(',')]);

  const currentParams = useMemo(() => queryString.parse(location.search), []);
  const selectedDemandPartner = useMemo(() => demand_partners.find(({ id }) => id === demand_partner_id), []);

  const selectFilter = (param: string, value: number | string) => {
    const newParams = { ...currentParams, [param]: value };
    const url = queryString.stringifyUrl({ url: location.pathname, query: newParams }, { skipNull: true });
    location.assign(url);
  };

  const defaultValues = {
    title: '',
    demand_partner_id,
    patient_ids: [],
  };

  const { form, syncFormProps, loading } = useSyncForm({
    url: admin_kustomer_patients_create_path(),
    method: 'post',
    formOptions: {
      defaultValues: defaultValues,
      resolver: yupResolver(kustomerCreatePatientSchema),
    },
  });

  useEffect(() => {
    selectedPatients.map((pd, index) => {
      return form.setValue(`patient_ids.${index}`, pd.id);
    });
  }, [selectedPatients]);

  return (
    <AdminLayout {...layout_props}>
      <EuiFlexGroup responsive={false}>
        <EuiFlexItem></EuiFlexItem>

        <EuiFlexItem>
          <EuiText textAlign="center">
            <h2>{patients.length.toLocaleString()} Patients</h2>
          </EuiText>
        </EuiFlexItem>

        <EuiFlexItem>
          <EuiFilterGroup style={{ width: 180, marginLeft: 'auto' }}>
            <FilterSelect
              options={demand_partners.map((p) => ({ text: p.name, value: p.id }))}
              selectedValue={selectedDemandPartner?.id}
              onSelect={(val) => selectFilter('demand_partner_id', val)}
              placeholder="Partner"
            />
          </EuiFilterGroup>
        </EuiFlexItem>
      </EuiFlexGroup>

      <EuiSpacer />

      {selectedPatients.length === 0 ? (
        <EuiText>
          <h3>Select patients from the map to get started.</h3>
          <p>(Hold down shift to select points)</p>
        </EuiText>
      ) : (
        <SyncForm {...syncFormProps}>
          <EuiPageContentHeader>
            <EuiPageContentHeaderSection>
              <EuiTitle>
                <h2>{selectedPatients.length} patients selected</h2>
              </EuiTitle>
            </EuiPageContentHeaderSection>
          </EuiPageContentHeader>
          <EuiSpacer size="m" />
          <EuiTitle size="s">
            <h4>Title Kustomer</h4>
          </EuiTitle>
          <MedTextField name="title" placeholder="Enter text..." />
          <MedHiddenField name="demand_partner_id" />
          <EuiSpacer size="m" />
          <EuiButton fill color="primary" type="submit" isLoading={loading}>
            Submit
          </EuiButton>
          {selectedPatients.map((pd, index) => (
            <MedHiddenField key={pd.id} name={`patient_ids.${index}`} />
          ))}
          <EuiSpacer size="m" />
          <InMemoryPatientsTable data={selectedPatients} fullAddress />
          <EuiSpacer size="m" />
          <EuiButton fill color="primary" type="submit" isLoading={loading}>
            Submit
          </EuiButton>
        </SyncForm>
      )}
    </AdminLayout>
  );
};
