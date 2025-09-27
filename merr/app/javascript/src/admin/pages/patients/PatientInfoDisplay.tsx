import React from 'react';
import { Patient, Program } from '@/common/types';
import { EuiFlexGroup, EuiFlexItem, EuiText } from '@elastic/eui';

interface PatientInfoDisplayProps {
  patient: Patient;
  useFieldLayout?: boolean;
  programs?: Program[];
}
// using programs rather than patient.programs because programs comes stripped down to only programs the current user is able to see
export const PatientInfoDisplay: React.FC<PatientInfoDisplayProps> = ({ patient, programs, useFieldLayout }) => {
  const Label = (props) => (
    <EuiText style={{ fontWeight: 'bold', fontSize: 12, paddingTop: 12 }}>
      <p>{props.children}</p>
    </EuiText>
  );
  const Value = (props) => (
    <div style={{ padding: '12px 0 12px 0', fontSize: 14, paddingLeft: 12 }}>{props.children}</div>
  );
  return (
    <div>
      <EuiFlexGroup direction="column">
        <EuiFlexItem style={{ backgroundColor: '#FAFBFD' }}>
          <EuiText style={{ padding: '8px 0 8px 16px' }}>
            <h3>Basic Info</h3>
          </EuiText>
        </EuiFlexItem>

        <EuiFlexGroup style={{ paddingLeft: 12 }}>
          <EuiFlexItem style={{ width: '45%' }} grow={false}>
            <Label>First Name</Label>
            <Value>{patient.first_name}</Value>
          </EuiFlexItem>
          <EuiFlexItem style={{ width: '45%' }} grow={false}>
            <Label>Last Name</Label>
            <Value>{patient.last_name}</Value>
          </EuiFlexItem>
        </EuiFlexGroup>

        <EuiFlexGroup style={{ paddingLeft: 12 }}>
          <EuiFlexItem style={{ width: '45%' }} grow={false}>
            <Label>Patient Medical Record Number #</Label>
            <Value>{patient.medical_record_number}</Value>
          </EuiFlexItem>
          <EuiFlexItem style={{ width: '45%' }} grow={false}>
            <Label>Date of Birth</Label>
            <Value>{patient.date_of_birth}</Value>
          </EuiFlexItem>
        </EuiFlexGroup>

        <EuiFlexGroup style={{ paddingLeft: 12 }}>
          <EuiFlexItem style={{ width: '45%' }} grow={false}>
            <Label>Address</Label>
            <Value>{patient?.address?.address_line_one}</Value>
          </EuiFlexItem>
          <EuiFlexItem style={{ width: '45%' }} grow={false}>
            <Label>Address (Optional)</Label>
            <Value>{patient?.address?.address_line_two}</Value>
          </EuiFlexItem>
        </EuiFlexGroup>

        <EuiFlexGroup style={{ paddingLeft: 12 }}>
          <EuiFlexItem style={{ width: '45%' }} grow={false}>
            <Label>City</Label>
            <Value>{patient?.address?.city}</Value>
          </EuiFlexItem>
          <EuiFlexItem style={{ width: '45%' }} grow={false}>
            <Label>State</Label>
            <Value>{patient?.address?.state}</Value>
          </EuiFlexItem>
        </EuiFlexGroup>

        <EuiFlexGroup style={{ paddingLeft: 12 }}>
          <EuiFlexItem style={{ width: '45%' }} grow={false}>
            <Label>Zip Code</Label>
            <Value>{patient?.address?.zipcode}</Value>
          </EuiFlexItem>
          <EuiFlexItem style={{ width: '45%' }} grow={false}>
            <Label>Phone Number</Label>
            <Value>{patient.phone_number}</Value>
          </EuiFlexItem>
        </EuiFlexGroup>

        <EuiFlexGroup style={{ paddingLeft: 12 }}>
          <EuiFlexItem style={{ width: '45%' }} grow={false}>
            <Label>Consent to Email</Label>
            <Value>{patient?.consent_to_email ? 'True' : 'False'}</Value>
          </EuiFlexItem>
          <EuiFlexItem style={{ width: '45%' }} grow={false}>
            <Label>Preferred Contact method</Label>
            <Value>{patient.preferred_contact_method ? patient.preferred_contact_method : 'Unknown'}</Value>
          </EuiFlexItem>
        </EuiFlexGroup>

        <EuiFlexGroup style={{ paddingLeft: 12 }}>
          <EuiFlexItem style={{ width: '45%' }} grow={false}>
            <Label>Email</Label>
            <Value>{patient?.contact_email}</Value>
          </EuiFlexItem>
          <EuiFlexItem style={{ width: '45%' }} grow={false}>
            <Label>Sex</Label>
            <Value>{patient.sex}</Value>
          </EuiFlexItem>
        </EuiFlexGroup>

        <EuiFlexGroup style={{ paddingLeft: 12 }}>
          <EuiFlexItem style={{ width: '45%' }} grow={false}>
            <Label>Gender</Label>
            <Value>{patient.gender}</Value>
          </EuiFlexItem>
          <EuiFlexItem style={{ width: '45%' }} grow={false}>
            <Label>Preferred Language</Label>
            <Value>{patient.preferred_language}</Value>
          </EuiFlexItem>
        </EuiFlexGroup>

        <EuiFlexGroup style={{ paddingLeft: 12 }}>
          {!useFieldLayout && (
            <EuiFlexItem style={{ width: '45%' }} grow={false}>
              <Label>Demand Partner</Label>
              <Value>{patient.demand_partner?.name}</Value>
            </EuiFlexItem>
          )}
          <EuiFlexItem style={{ width: '45%' }} grow={false}>
            <Label>Program</Label>
            <Value>
              {programs?.map((p) => (
                <div key={p.name}>{p.name}</div>
              ))}
            </Value>
          </EuiFlexItem>
        </EuiFlexGroup>
      </EuiFlexGroup>
    </div>
  );
};
