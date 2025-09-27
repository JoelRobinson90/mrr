import React, { useState, useEffect, useMemo } from 'react';
import { EuiFlexGroup, EuiFlexItem, EuiText, EuiButton, EuiButtonEmpty, EuiHorizontalRule } from '@elastic/eui';
import { MedTextField, MedMaskedInput, MedSelect, MedComboBox, MedCheckbox } from '@/common/components/forms';
import { DemandPartner, Program, Patient, PatientPrograms, Address, User } from '@/common/types';
import * as yup from 'yup';
import { slashDateToDashDate, DASH_DATE_REGEX } from '@/common/utils/dates/dates';

import { useForm } from 'react-hook-form';
import { SyncForm } from '@/common/components/SyncForm/SyncForm';
import { yupResolver } from '@hookform/resolvers';
import moment from 'moment';
import { uniq } from 'lodash';

export const patientSchema = yup.object().shape({
  patient: yup.object().shape({
    first_name: yup.string().label('First Name').required(),
    last_name: yup.string().label('Last name').required(),
    date_of_birth: yup
      .string()
      .label('Date of Birth')
      .required()
      .transform(slashDateToDashDate)
      .matches(DASH_DATE_REGEX, 'Please provide a valid date.'),
    preferred_contact_method: yup.string().label('Preferred Contact Method'),
    consent_to_email: yup.boolean().label('Consent To Email'),
    phone_number: yup.string().label('Phone Number').required(),
    demand_partner_id: yup.string().label('Referring Organization').required(),
    medical_record_number: yup.string().label('Patient Medical Record Number #').required(),
    address_attributes: yup.object().shape({
      address_line_one: yup.string().label('Address Line One').required(),
      city: yup.string().label('City').required(),
      state: yup.string().label('State').required(),
      zipcode: yup.string().label('Zipcode').required(),
    }),
  }),
});

interface PatientFormProps {
  demandPartners: Array<DemandPartner>;
  sexes: Array<string>;
  genders: Array<string>;
  languages: Array<string>;
  isNew?: boolean;
  programs?: Array<Program> | Array<PatientPrograms>;
  patient?: Patient;
  setIsEditingPatient?: Function;
  buttonLocation?: string;
  address?: Address;
  user?: User;
  all_programs?: any;
  useFieldLayout?: boolean;
  consent_to_email?: boolean;
  preferred_contact_method?: string;
}

export const PatientForm: React.FC<PatientFormProps> = ({
  demandPartners,
  sexes,
  genders,
  languages,
  programs = [],
  setIsEditingPatient,
  buttonLocation = 'bottom',
  patient,
  address,
  all_programs,
  useFieldLayout,
}) => {
  const createOptions = (options) => {
    return [{ value: null, text: '' }].concat(
      options?.map((option) => {
        const { name } = option || {};
        const id = option?.id;
        return {
          value: id || option,
          text: name || option,
        };
      }),
    );
  };

  const {
    id,
    medical_record_number,
    first_name,
    last_name,
    date_of_birth,
    phone_number,
    gender,
    sex,
    preferred_pronouns,
    preferred_language,
    demand_partner,
    race,
    ethnicity,
    contact_email,
    consent_to_email,
    preferred_contact_method,
  } = patient;
  const defaultValues: any = {
    medical_record_number,
    first_name,
    last_name,
    date_of_birth: moment(date_of_birth).format('MM/DD/YYYY'),
    address_attributes: {
      id: address?.id,
      address_line_one: address?.address_line_one || '',
      address_line_two: address?.address_line_two || '',
      county: address?.county || '',
      city: address?.city || '',
      state: address?.state || '',
      zipcode: address?.zipcode || '',
    },
    phone_number,
    consent_to_email: consent_to_email || false,
    preferred_contact_method,
    gender,
    sex,
    race,
    ethnicity,
    preferred_pronouns,
    preferred_language,
    demand_partner_id: demand_partner?.id,
    contact_email: contact_email,
    program_ids: programs?.map((p) => p?.id) || [],
  };

  const form = useForm({
    defaultValues: {
      patient: defaultValues,
    },
    resolver: yupResolver(patientSchema),
  });

  const contactMethods = ['Email', 'Phone', 'SMS'];

  const [isNewPatient, setIsNewPatient] = useState(id === null);
  const fieldOrAdmin = useFieldLayout ? 'field' : 'admin';
  const targetUrl = id ? `/${fieldOrAdmin}/patients/${id}` : `/${fieldOrAdmin}/patients`;
  const targetMethod = id ? 'put' : 'post';

  const demandPartnersOptions = createOptions(demandPartners);
  const gendersOptions = createOptions(genders);
  const sexesOptions = createOptions(sexes);
  const languagesOptions = createOptions(languages);
  const contactMethodOptions = createOptions(contactMethods);
  const { watch, setValue } = form;
  const currentDemandPartner = watch('patient.demand_partner_id');

  // if demand partner changes, calculate the appropriate programs to have as options
  const programOptions = useMemo(() => {
    if (currentDemandPartner) {
      let filteredPrograms;

      all_programs[0]?.demand_partner &&
        (filteredPrograms = all_programs.filter((p) => p?.demand_partner?.id == currentDemandPartner));

      return filteredPrograms?.map((p) => ({
        label: p.name,
        value: p?.id,
        disabled: !p?.active,
      }));
    }
    return [];
  }, [currentDemandPartner]);
  // if demand partner changes and it only has 1 program then auto select program
  useEffect(() => {
    if (currentDemandPartner && programOptions?.length === 1) {
      setValue('patient.program_ids', [programOptions[0]?.value]);
    } else if (currentDemandPartner !== demand_partner?.id) {
      setValue('patient.program_ids', []);
    }
  }, [currentDemandPartner]);

  const Label = (props) => (
    <EuiText style={{ fontWeight: 'bold', fontSize: 12 }}>
      <p>{props.children}</p>
    </EuiText>
  );
  const inactiveProgramsList = programs
    // This extra map is necessary since it sends an error because the variable accepts two different data types.
    ?.map((m) => m)
    ?.filter((p) => !p?.active)
    ?.map((pi) => pi.id);

  const externalOnchangeComboBoxPrograms = (onChange, options) => {
    let optionsValues = options.map((o) => o.value);
    if (inactiveProgramsList) optionsValues = uniq(optionsValues.concat(inactiveProgramsList));
    onChange(optionsValues);
  };

  return (
    <SyncForm form={form} url={targetUrl} method={targetMethod}>
      {buttonLocation === 'top' && (
        <div
          style={{
            display: 'flex',
            flexDirection: 'row',
            justifyContent: 'flex-end',
            width: '100%',
            marginBottom: '10px',
          }}
        >
          <EuiFlexItem>
            <EuiButtonEmpty
              style={{ maxWidth: '153px', paddingRight: 12 }}
              onClick={() => setIsEditingPatient(false)}
              type="button"
            >
              Cancel
            </EuiButtonEmpty>
          </EuiFlexItem>
          <EuiButton type="submit">Save</EuiButton>
        </div>
      )}

      <EuiFlexGroup direction="column">
        <EuiFlexItem style={{ backgroundColor: '#FAFBFD' }}>
          <EuiText style={{ padding: '8px 0 8px 16px' }}>
            <h3>Basic Info</h3>
          </EuiText>
        </EuiFlexItem>
        <EuiFlexGroup style={{ paddingLeft: 12, paddingTop: 12 }}>
          <EuiFlexItem style={{ width: '45%' }} grow={false}>
            <Label>First Name</Label>
            <MedTextField style={{ borderRadius: 12 }} name="patient.first_name" />
          </EuiFlexItem>
          <EuiFlexItem style={{ width: '45%' }} grow={false}>
            <Label>Last Name</Label>
            <MedTextField style={{ borderRadius: 12 }} name="patient.last_name" />
          </EuiFlexItem>
        </EuiFlexGroup>
        <EuiFlexGroup style={{ paddingLeft: 12, paddingTop: 12 }}>
          <EuiFlexItem style={{ width: '45%' }} grow={false}>
            <Label>Patient Medical Record Number #</Label>
            <MedTextField style={{ borderRadius: 12 }} name="patient.medical_record_number" readOnly={!isNewPatient} />
          </EuiFlexItem>
          <EuiFlexItem style={{ width: '45%' }} grow={false}>
            <Label>Date of Birth</Label>
            <MedMaskedInput style={{ borderRadius: 12 }} mask="99/99/9999" name="patient.date_of_birth" />
          </EuiFlexItem>
        </EuiFlexGroup>
        <EuiFlexGroup style={{ paddingLeft: 12, paddingTop: 12 }}>
          <EuiFlexItem style={{ width: '45%' }} grow={false}>
            <Label>Address</Label>
            <MedTextField style={{ borderRadius: 12 }} name="patient.address_attributes.address_line_one" />
          </EuiFlexItem>
          <EuiFlexItem style={{ width: '45%' }} grow={false}>
            <Label>Address (Optional)</Label>
            <MedTextField style={{ borderRadius: 12 }} name="patient.address_attributes.address_line_two" />
          </EuiFlexItem>
        </EuiFlexGroup>
        <EuiFlexGroup style={{ paddingLeft: 12, paddingTop: 12 }}>
          <EuiFlexItem style={{ width: '45%' }} grow={false}>
            <Label>City</Label>
            <MedTextField style={{ borderRadius: 12 }} name="patient.address_attributes.city" />
          </EuiFlexItem>
          <EuiFlexItem style={{ width: '45%' }} grow={false}>
            <Label>State</Label>
            <MedTextField style={{ borderRadius: 12 }} name="patient.address_attributes.state" />
          </EuiFlexItem>
        </EuiFlexGroup>
        <EuiFlexGroup style={{ paddingLeft: 12, paddingTop: 12 }}>
          <EuiFlexItem style={{ width: '45%' }} grow={false}>
            <Label>Zip Code</Label>
            <MedTextField style={{ borderRadius: 12 }} name="patient.address_attributes.zipcode" />
          </EuiFlexItem>
          <EuiFlexItem style={{ width: '45%' }} grow={false}>
            <Label>Phone Number (Primary)</Label>
            <MedTextField style={{ borderRadius: 12 }} name="patient.phone_number" />
          </EuiFlexItem>
          <MedTextField name="patient.address_attributes.id" hidden />
        </EuiFlexGroup>
        <EuiFlexGroup style={{ paddingLeft: 12, paddingTop: 12 }}>
          <EuiFlexItem style={{ width: '45%' }} grow={false}>
            <Label>Email</Label>
            <MedTextField style={{ borderRadius: 12 }} name="patient.contact_email" />
          </EuiFlexItem>
          <EuiFlexItem style={{ width: '45%' }} grow={false}>
            <Label>Sex</Label>
            <MedSelect style={{ borderRadius: 6 }} options={sexesOptions} name="patient.sex" />
          </EuiFlexItem>
          <MedTextField name="patient.user_attributes.id" hidden />
        </EuiFlexGroup>
        <EuiFlexGroup style={{ paddingLeft: 12, paddingTop: 12 }}>
          <EuiFlexItem style={{ width: '45%' }} grow={false}>
            <Label>Consent To Email</Label>
            <MedCheckbox style={{ borderRadius: 12 }} name="patient.consent_to_email" />
          </EuiFlexItem>
          <EuiFlexItem style={{ width: '45%' }} grow={false}>
            <Label>Preferred Contact Method</Label>
            <MedSelect
              style={{ borderRadius: 6 }}
              options={contactMethodOptions}
              name="patient.preferred_contact_method"
            />
          </EuiFlexItem>
        </EuiFlexGroup>
        <EuiFlexGroup style={{ paddingLeft: 12, paddingTop: 12 }}>
          <EuiFlexItem style={{ width: '45%' }} grow={false}>
            <Label>Gender</Label>
            <MedSelect options={gendersOptions} name="patient.gender" style={{ borderRadius: 6 }} />
          </EuiFlexItem>
          <EuiFlexItem style={{ width: '45%' }} grow={false}>
            <Label>Preferred Language</Label>
            <MedSelect options={languagesOptions} name="patient.preferred_language" style={{ borderRadius: 6 }} />
          </EuiFlexItem>
        </EuiFlexGroup>
        {!useFieldLayout ? (
          <EuiFlexGroup style={useFieldLayout ? { display: 'hidden' } : { paddingLeft: 12, paddingTop: 12 }}>
            <EuiFlexItem style={{ width: '45%' }} grow={false}>
              <Label>Demand Partner</Label>
              <MedSelect options={demandPartnersOptions} name="patient.demand_partner_id" style={{ borderRadius: 6 }} />
            </EuiFlexItem>
            <EuiFlexItem style={{ display: 'hidden', width: '45%' }} grow={false}>
              <Label style={{ display: 'hidden' }}>Program</Label>
              <MedComboBox
                width="100%"
                name="patient.program_ids"
                options={programOptions}
                placeholder="Select a program from the list"
                externalOnchange={externalOnchangeComboBoxPrograms}
              />
            </EuiFlexItem>
          </EuiFlexGroup>
        ) : (
          <>
            <EuiFlexItem style={{ display: 'hidden', width: '45%' }} grow={false}>
              <Label style={{ display: 'hidden' }}>Program</Label>

              <MedComboBox
                disabled
                width="100%"
                name="patient.program_ids"
                options={programOptions}
                placeholder="Select a program from the list"
              />
            </EuiFlexItem>
            <MedTextField name="patient.demand_partner_id" hidden />
          </>
        )}
        {buttonLocation === 'bottom' && (
          <>
            <EuiHorizontalRule margin="m" style={{ width: '100%', height: '1px', backgroundColor: '#d3dae6' }} />
            <div
              style={{
                display: 'flex',
                flexDirection: 'row',
                justifyContent: 'flex-end',
                width: '100%',
              }}
            >
              <EuiButtonEmpty
                style={{ maxWidth: '153px', paddingRight: 12 }}
                onClick={() => setIsEditingPatient(false)}
                type="button"
              >
                Cancel
              </EuiButtonEmpty>

              <EuiButton type="submit">Save</EuiButton>
            </div>
          </>
        )}
      </EuiFlexGroup>
    </SyncForm>
  );
};
