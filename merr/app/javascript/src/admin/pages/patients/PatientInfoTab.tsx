import React from 'react';
import { Address, DemandPartner, Patient, Program, User } from '@/common/types';
import { PatientForm } from './PatientForm/PatientForm';
import { PatientInfoDisplay } from './PatientInfoDisplay';

interface PatientInfoTabProps {
  patient: Patient;
  address: Address;
  demand_partners: Array<DemandPartner>;
  sexes: Array<string>;
  genders: Array<string>;
  languages: Array<string>;
  races?: Array<string>;
  ethnicities?: Array<string>;
  phone_types?: Array<string>;
  programs?: Array<Program>;
  user?: User;
  all_programs?: any;
  isEditingPatient?: Boolean;
  setIsEditingPatient?: Function;
  useFieldLayout?: boolean;
}

export const PatientInfoTab: React.FC<PatientInfoTabProps> = ({
  address,
  demand_partners,
  genders,
  sexes,
  languages,
  programs,
  patient,
  user,
  all_programs,
  isEditingPatient,
  setIsEditingPatient,
  useFieldLayout,
}) => {
  return isEditingPatient ? (
    <PatientForm
      user={user}
      patient={patient}
      address={address}
      demandPartners={demand_partners}
      sexes={sexes}
      genders={genders}
      languages={languages}
      programs={programs}
      setIsEditingPatient={setIsEditingPatient}
      buttonLocation="top"
      all_programs={all_programs}
      useFieldLayout={useFieldLayout}
    />
  ) : (
    <PatientInfoDisplay patient={patient} programs={programs} useFieldLayout={useFieldLayout} />
  );
};
