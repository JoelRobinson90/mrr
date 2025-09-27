import React, { useEffect, useMemo, useState } from 'react';
import {
  EuiButton,
  EuiButtonEmpty,
  EuiFlexGroup,
  EuiFlexItem,
  EuiHorizontalRule,
  EuiModal,
  EuiModalBody,
  EuiModalFooter,
  EuiModalHeader,
  EuiModalHeaderTitle,
  EuiOverlayMask,
  EuiSpacer,
  EuiCheckboxGroup,
  EuiText,
} from '@elastic/eui';
import queryString from 'query-string';

import { Patient, Program, VisitType } from '@/common/types/index';
import { useSyncForm } from '@/common/hooks/useSyncForm/useSyncForm';
import { SyncForm } from '@/common/components/SyncForm/SyncForm';
import { MedComboBox, MedTextField } from '@/common/components/forms';
import { find, uniqBy } from 'lodash';
import {
  admin_patient_path,
  admin_patient_visits_path,
  field_patient_path,
  field_patient_visits_path,
} from '@/common/routes';

type ServiceRequestPartial = {
  id: string | number;
  programId: string | number;
  serviceId: string | number;
};

interface CreateVisitModalProps {
  programs: Program[];
  closeModal: () => void | null;
  patient: Patient;
  editWarning?: boolean;
  onButtonClick?: (args: any) => void;
  selectedProgramId?: string;
  selectedVisitTypeId?: string;
  currentServiceIds?: string[];
  serviceRequests?: ServiceRequestPartial[];
  current_user?: any;
  redirectPath?: string;
}

const calculateDuration = (visitType: VisitType, services): number => {
  if (!visitType || !services?.length) return 0;
  return (
    (visitType.duration || 0) +
    services.reduce((sum, service) => (service.duration ? sum + parseInt(service.duration) : sum), 0)
  );
};

export const CreateVisitModal: React.FC<CreateVisitModalProps> = ({
  programs = [],
  closeModal,
  patient,
  editWarning = false,
  selectedProgramId,
  selectedVisitTypeId,
  currentServiceIds = [],
  serviceRequests = [],
  current_user,
  redirectPath,
}) => {
  const currentParams = useMemo(() => queryString.parse(location.search), []);
  const servicesIds = currentParams?.service_ids?.toString()?.split(',');

  const programOptions = programs
    .filter((pf) => pf.active)
    ?.map((p) => {
      return {
        label: p.name,
        value: p?.id?.toString(),
        visitTypes: p?.visit_types,
        services: p?.services,
        id: p?.id?.toString(),
      };
    });

  const [serviceIds, setServiceIds] = useState<Set<string>>(() => new Set(currentServiceIds));

  const cancelModal = () => {
    const patientId = patient?.id;
    if (location.search) {
      if (isFieldAccount()) {
        window.location.href = field_patient_path(patientId);
      } else {
        window.location.href = admin_patient_path(patientId);
      }
    } else {
      closeModal();
    }
  };

  const programsCacheKey = programs?.map((p) => p.id).join(',') || '';

  const initialFormValues = useMemo(() => {
    const { visit_type_id, program_id } = currentParams;
    let duration = null;

    if (program_id && visit_type_id) {
      const program = programs.find((p) => p.id.toString() === program_id.toString());
      const visitType = program?.visit_types.find((v) => v.id.toString() === visit_type_id.toString());
      const filterServices = visitType?.services.filter((s) => servicesIds.includes(`service_${s.id}`));

      duration = calculateDuration(visitType, filterServices);
    }

    const defaultProgramId = program_id
      ? [program_id]
      : selectedProgramId
      ? [selectedProgramId]
      : programOptions?.length > 0 && programOptions?.length === 1
      ? [programOptions[0].id.toString()]
      : [];

    // if the first time the patient only belongs to 1 program and the program has 1 visit type then auto select visit type.
    const ifOnlyOneProgramAndOneVisitType =
      programs?.length && programs?.length === 1 && programs[0].visit_types?.length === 1;
    const defaultVisitTypeId = visit_type_id
      ? [visit_type_id]
      : selectedVisitTypeId
      ? [selectedVisitTypeId]
      : ifOnlyOneProgramAndOneVisitType
      ? [programs[0].visit_types[0].id.toString()]
      : [];

    const defaultDuration = duration
      ? duration
      : currentParams.duration ||
        (ifOnlyOneProgramAndOneVisitType
          ? calculateDuration(programs[0].visit_types[0], programs[0].visit_types[0].services)
          : null);

    return {
      program_id: defaultProgramId,
      visit_type_id: defaultVisitTypeId,
      duration: defaultDuration,
    };
  }, [programsCacheKey, currentParams.program_id, currentParams.visit_type_id]);

  const { form: getSchedulesForm, syncFormProps: getSchedulesFormProps } = useSyncForm({
    formId: 'getSchedulesForm',
    url: '',
    method: 'get',
    formOptions: {
      defaultValues: initialFormValues,
    },
  });

  const { watch, setValue, reset } = getSchedulesForm;

  useEffect(() => {
    getSchedulesForm.reset(initialFormValues);
  }, [programsCacheKey]);

  const currentProgramId = watch('program_id');
  const currentVisitTypeId = watch('visit_type_id');
  const currentDuration = watch('duration');

  const servicesCacheKey = Array.from(serviceIds).sort().join(',');
  const isFieldAccount = () => {
    const fieldAccountTypes = ['FieldProvider', 'ExternalAccount'];
    return fieldAccountTypes.includes(current_user?.account_type);
  };

  const currentProgram = useMemo(() => {
    if (currentProgramId?.length) {
      return find(programs, (p) => `${p.id}` === `${currentProgramId[0]}`);
    }
    return null;
  }, [currentProgramId]);

  const visitTypeOptions = useMemo(() => {
    if (currentProgram?.id) {
      const visitTypes = currentProgram?.visit_types;
      return visitTypes?.map((vt) => ({ label: vt.name, value: vt.id?.toString() })) || [];
    }
    return [];
  }, [currentProgram?.id]);

  const currentVisitType = useMemo(() => {
    return currentProgram?.visit_types?.find((vt) => `${vt.id}` === `${currentVisitTypeId[0]}`);
  }, [currentVisitTypeId]);

  const formatServiceId = (service) => `service_${service?.id}`;

  const serviceOptions = useMemo(() => {
    if (currentProgram?.id && currentVisitType?.id) {
      const programServices = currentProgram.services;
      const visitTypeServices = currentVisitType.services;
      let services = [...programServices, ...visitTypeServices];
      services = uniqBy(services, 'id');
      return services.map((s) => ({ id: formatServiceId(s), label: s.name, duration: s.duration }));
    }
    return [];
  }, [currentProgramId, currentVisitTypeId]);

  const onSelectService = (serviceId: string | number): void => {
    serviceId = serviceId.toString();

    const serviceIdsCopy = new Set(serviceIds);
    if (serviceIdsCopy.has(serviceId)) {
      serviceIdsCopy.delete(serviceId);
    } else {
      serviceIdsCopy.add(serviceId);
    }

    setServiceIds(serviceIdsCopy);
  };

  const goToSchedulePage = (): void => {
    const currentParams = queryString.parse(location.search);
    const newParams = {
      ...currentParams,
      program_id: currentProgram?.id || '',
      visit_type_id: currentVisitType?.id || '',
      duration: currentDuration || '',
      service_ids: Array.from(serviceIds).join(','),
    };
    let redirectUrl;

    if (redirectPath) {
      redirectUrl = new URL(redirectPath, window.location.origin);
      redirectUrl.search = queryString.stringify(newParams);
    } else {
      redirectUrl = isFieldAccount()
        ? field_patient_visits_path(patient.id, newParams)
        : admin_patient_visits_path(patient.id, newParams);
    }

    // If already on scheduler page, replace location in history to avoid back button issues
    if (editWarning) {
      window.location.replace(redirectUrl);
    } else {
      window.location.assign(redirectUrl);
    }
  };

  const requestedServicesByProgramId: { [programId: string]: string[] } = useMemo(() => {
    return serviceRequests.reduce((acc, req) => {
      const programId = req.programId.toString();
      acc[programId] = acc[programId] || [];
      acc[programId].push(`service_${req.serviceId}`);
      return acc;
    }, {});
  }, [serviceRequests.length]);

  // if program changes and it only has 1 visit type then auto select that only visit type.
  useEffect(() => {
    if (currentProgram?.id && currentProgram?.visit_types?.length === 1) {
      setValue('visit_type_id', [currentProgram?.visit_types[0].id.toString()]);
    } else {
      // setValue('visit_type_id', []);
      setValue('duration', 0);
      setServiceIds(new Set());
    }
  }, [currentProgramId]);

  // prefill visit type services and requested services
  useEffect(() => {
    if (currentVisitType) {
      const prefilledServiceIds = currentVisitType.services.map((s) => formatServiceId(s));
      const requestedServiceIds = requestedServicesByProgramId[currentProgram.id.toString()] || [];
      setServiceIds((currentServiceIds) => new Set([...prefilledServiceIds, ...requestedServiceIds]));
    }
    if (currentParams?.service_ids) {
      const objServiceIds: Set<string> = new Set();
      servicesIds.forEach((id) => objServiceIds.add(`${id}`));
      setServiceIds(objServiceIds);
    }
  }, [currentVisitType?.id, servicesIds?.length, currentParams?.service_ids]);

  const isButtonDisabled =
    !currentProgramId ||
    currentVisitTypeId.length === 0 ||
    !currentDuration ||
    parseInt(currentDuration.toString()) === 0;

  const selectedServices = useMemo(() => {
    return serviceOptions.reduce((acc, service) => {
      return { ...acc, [service.id]: serviceIds.has(service.id.toString()) };
    }, {});
  }, [servicesCacheKey, serviceIds]);

  useEffect(() => {
    if (currentVisitType?.id) {
      const newDuration = calculateDuration(
        currentVisitType,
        serviceOptions.filter((option) => selectedServices[option.id]),
      );
      setValue('duration', newDuration);
    }
  }, [currentVisitTypeId, servicesCacheKey]);

  return (
    <EuiOverlayMask>
      <EuiModal onClose={cancelModal}>
        <EuiModalHeader>
          <EuiModalHeaderTitle>Add Visit</EuiModalHeaderTitle>
        </EuiModalHeader>

        <EuiHorizontalRule margin="none" />
        <EuiSpacer size="m" />

        <EuiModalBody>
          {editWarning && (
            <EuiText>
              Editing this information will present new results for the visit and this action cannot be undone
            </EuiText>
          )}

          <EuiSpacer size="m" />
          <SyncForm {...getSchedulesFormProps}>
            <EuiText style={{ fontWeight: 'bold' }}>
              <p>Program</p>
            </EuiText>
            <MedComboBox
              width="100%"
              name="program_id"
              disabled={programOptions?.length === 1}
              options={programOptions}
              placeholder={
                programOptions?.length ? 'Please select a program from the list' : 'Patient has no active programs'
              }
              singleSelection={{ asPlainText: true }}
              isClearable={false}
            />
            <EuiSpacer size="m" />
            <EuiText style={{ fontWeight: 'bold' }}>
              <p>Visit Type</p>
            </EuiText>

            <MedComboBox
              width="100%"
              name="visit_type_id"
              disabled={visitTypeOptions?.length === 1}
              options={visitTypeOptions}
              placeholder="Please select a visit type the list"
              singleSelection={{ asPlainText: true }}
              isClearable={false}
            />
            <EuiSpacer size="m" />
            <EuiText style={{ fontWeight: 'bold' }}>
              <p>Services</p>
            </EuiText>
            <EuiCheckboxGroup
              data-testid="services-group"
              options={serviceOptions}
              idToSelectedMap={selectedServices}
              onChange={(id) => onSelectService(id)}
            />
            <EuiSpacer size="m" />
            <EuiText style={{ fontWeight: 'bold' }}>
              <p>Visit Duration</p>
            </EuiText>
            <MedTextField style={{ width: '100px' }} name="duration" placeholder="duration" />
          </SyncForm>
        </EuiModalBody>
        <EuiModalFooter>
          <EuiFlexGroup justifyContent="flexEnd" responsive={false}>
            <EuiFlexItem grow={false}>
              <EuiButtonEmpty color="primary" flush="left" onClick={cancelModal}>
                Cancel
              </EuiButtonEmpty>
            </EuiFlexItem>
            <EuiFlexItem grow={false}>
              <EuiButton isDisabled={isButtonDisabled} onClick={() => goToSchedulePage()} fill type="submit">
                Get Schedules
              </EuiButton>
            </EuiFlexItem>
          </EuiFlexGroup>
        </EuiModalFooter>
      </EuiModal>
    </EuiOverlayMask>
  );
};
