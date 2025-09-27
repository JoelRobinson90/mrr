import { EuiText, EuiComboBox, EuiIcon } from '@elastic/eui';
import React, { FC, useCallback, useEffect, useState } from 'react';
import { usePatientsIndexQuery } from '@/generated/graphql';
import { Patient, AlayacareVisit } from '@/common/types';

const PatientSearch: FC<{
  patient: Patient;
  selectedOptions: { label: string }[];
  setSelected: (data: { label: string }[]) => void;
  groupVisits: any;
  visit: AlayacareVisit;
}> = ({ selectedOptions, setSelected, patient, groupVisits, visit }) => {
  const [isLoading, setLoading] = useState(false);
  const [options, setOptions] = useState([]);
  let searchTimeout;

  useEffect(() => {
    onSearchChange('');
  }, []);

  const { refetch, loading, error, data: patientSearchData } = usePatientsIndexQuery({
    onCompleted: (res) => {
      const labels = createLabelOptions(res.getPatients);
      setOptions(labels);
    },
  });

  const createLabelOptions = (array) => {
    const optionsWithoutCurrentPatients = [];
    const patientIdsOnVisit = groupVisits ? groupVisits?.map((v) => v?.patient.id.toString()) : [];
    patientIdsOnVisit.push(patient.id.toString());
    array?.forEach(({ id, medical_record_number, firstName, lastName }) => {
      if (!patientIdsOnVisit.includes(id?.toString())) {
        optionsWithoutCurrentPatients.push({ label: `${firstName} ${lastName} - ${medical_record_number}`, id });
      }
    });
    return optionsWithoutCurrentPatients;
  };

  const onSearchChange = useCallback((searchValue) => {
    setLoading(true);
    refetch({ search: searchValue, programId: visit?.program?.id?.toString() });

    clearTimeout(searchTimeout);
    searchTimeout = setTimeout(() => {
      setLoading(false);
    }, 1200);
  }, []);

  return (
    <>
      <EuiText style={{ fontWeight: 700, fontSize: '22px', color: 'black' }}>Adding Patient</EuiText>
      <EuiText style={{ marginBottom: '4px', marginTop: '16px', fontSize: '12px', color: '#0071C2', fontWeight: 700 }}>
        Patient Name
      </EuiText>
      <EuiComboBox
        prepend={
          <EuiIcon
            type="search"
            style={{ backgroundColor: '#FBFCFD', color: '#6a717d', paddingRight: 0, width: 'auto' }}
          />
        }
        aria-label="Select patient"
        placeholder="Select"
        async
        options={options}
        singleSelection={{ asPlainText: true }}
        selectedOptions={selectedOptions}
        isLoading={isLoading}
        onChange={(text) => setSelected(text)}
        onSearchChange={onSearchChange}
        renderOption={({ label }) => {
          const patientInfo = label?.split('-');
          const patientName = patientInfo[0];
          const medicalRecordNumber = patientInfo[1];
          return (
            <span style={{ color: '#343741' }}>
              {patientName}
              <span style={{ color: '#69707D' }}> ID: {medicalRecordNumber}</span>
            </span>
          );
        }}
      />
    </>
  );
};

export default PatientSearch;
