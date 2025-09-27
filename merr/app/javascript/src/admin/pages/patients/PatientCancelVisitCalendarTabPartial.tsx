import React, { FC, useEffect, useMemo, useState } from 'react';
import { AdminPageProps } from '@/admin/components/AdminLayout/AdminLayout';
import { MedComboBox, MedHiddenField, MedTextArea } from '@/common/components/forms';
import { SyncForm } from '@/common/components/SyncForm/SyncForm';
import { useSyncForm } from '@/common/hooks/useSyncForm/useSyncForm';
import { admin_alayacare_cancel_visit_path, field_cancel_visit_path } from '@/common/routes';
import { EuiFlexItem } from '@elastic/eui';
import { useFormContext, useWatch } from 'react-hook-form';
import { useGetVisitQuery } from '@/generated/graphql';
import { PlusOneWarning } from './PlusOneWarning';

import { yupResolver } from '@hookform/resolvers';
import * as yup from 'yup';
import { useCancelVisitMutationMutation } from '@/generated/graphql';
import { useFlashToast } from '@/common/components/FlashToast/FlashToast';

interface CancellationReasons {
  code: string;
  description: string;
  id: number;
}

interface PatientCancelVisitCalendarTabPartialProps extends AdminPageProps {
  patient_id: string;
  alayacare_visit_id: string;
  cancellation_reasons: CancellationReasons[];
  visit: any;
  note: any;
  cancel_code: number | null;
  redirectPath: string;
  current_user?: any;
  hidden_label: boolean;
}

export const cancelVisitSchema = yup.object().shape({
  cancel_code_id: yup
    .array(yup.string().required())
    .min(1)
    .label('Cancellation Reason')
    .typeError('Cancellation reason is required')
    .required(),
});

const CancellationReason: FC<{ cancellationReasons: CancellationReasons[] }> = ({ cancellationReasons }) => {
  const { control } = useFormContext();
  const cancellationReasonId = useWatch({
    control,
    name: 'cancel_code_id',
  });

  const cancellationReasonsDescription = useMemo(() => {
    const id = cancellationReasonId ? cancellationReasonId[0] : [];
    const { description } = cancellationReasons?.find((c) => c.id === id) || {};
    return description;
  }, [cancellationReasonId]);

  if (!cancellationReasonsDescription) return null;

  return (
    <>
      <h4 style={{ fontWeight: 500, fontSize: '14px', marginBottom: '8px', marginTop: '16px', color: '#525252' }}>
        Description
      </h4>
      <p style={{ fontWeight: 400, fontSize: '12px', color: 'black' }}>{cancellationReasonsDescription}</p>
    </>
  );
};

export const PatientCancelVisitCalendarTabPartial: FC<PatientCancelVisitCalendarTabPartialProps> = ({
  patient_id,
  alayacare_visit_id,
  visit,
  note,
  cancel_code,
  cancellation_reasons = [],
  redirectPath,
  current_user,
}) => {
  const cancellationKeys = cancellation_reasons.map((r) => r.id).join();
  const [plusOneWarningUnderstood, setPlusOneWarningUnderstood] = useState(false);
  const { addAlert } = useFlashToast();

  const options = useMemo(() => {
    return cancellation_reasons.map((reason) => ({ label: reason.code, value: reason.id }));
  }, [cancellationKeys]);

  const { refetch: refetchVisitData, data: visitDataFetched, loading: loadingVisitData } = useGetVisitQuery({
    variables: {
      visit_id: visit?.external_id || '',
    },
    fetchPolicy: 'no-cache',
  });

  const isFieldAccount = () => {
    const fieldAccountTypes = ['FieldProvider', 'ExternalAccount'];
    return fieldAccountTypes.includes(current_user?.account_type);
  };

  const [cancelVisitMutationMutation, { loading: loadingSubmit }] = useCancelVisitMutationMutation();

  const onFormSubmit = async (value) => {
    const { data, errors } = await cancelVisitMutationMutation({
      variables: {
        id: visit?.id,
        ma_id: visit?.ma_id,
        cancel_code_id: value?.cancel_code_id[0],
        note: value?.description,
      },
    });
    if (data?.cancelVisit?.visit?.id) {
      window.location.reload();
    } else {
      addAlert(`Error cancelling visit: ${errors}`);
    }
  };

  const { syncFormProps } = useSyncForm({
    url: isFieldAccount() ? field_cancel_visit_path() : admin_alayacare_cancel_visit_path(),
    method: 'post',
    formId: 'cancelVisitForm',
    formOptions: {
      defaultValues: {
        cancel_code_id: cancel_code ? [cancel_code] : null,
        patient_id,
        alayacare_visit_id: alayacare_visit_id,
        external_id: visit?.external_id,
        redirect_path: redirectPath,
        description: note?.content || '',
      },
      resolver: yupResolver(cancelVisitSchema),
    },
    onFormSubmit: onFormSubmit,
  });

  return (
    <EuiFlexItem grow={false}>
      <SyncForm {...syncFormProps}>
        <div style={{ margin: 'auto', width: '400px' }}>
          <MedHiddenField name="patient_id" readOnly hidden />
          <MedHiddenField name="alayacare_visit_id" readOnly hidden />
          <MedHiddenField name="redirect_path" readOnly hidden />
          <MedHiddenField name="external_id" readOnly hidden />
          {visit?.visit_group_id && (
            <PlusOneWarning
              visitGroup={visitDataFetched?.getVisit?.visitGroup}
              plusOneWarningUnderstood={plusOneWarningUnderstood}
              setPlusOneWarningUnderstood={setPlusOneWarningUnderstood}
              current_user={current_user}
              verb={'cancel'}
              currentPatientId={patient_id}
            />
          )}
          {(!visitDataFetched?.getVisit?.visitGroup || plusOneWarningUnderstood === true) && (
            <>
              <h4 style={{ fontWeight: 700, fontSize: '12px', marginBottom: '4px', color: 'black' }}>
                Cancelation Reason
              </h4>
              <MedComboBox
                width="100%"
                name="cancel_code_id"
                options={options || []}
                placeholder="Select a cancellation reason"
                singleSelection={{ asPlainText: true }}
              />
              <CancellationReason cancellationReasons={cancellation_reasons} />
              <h4 style={{ fontWeight: 700, fontSize: '12px', marginBottom: '4px', marginTop: '16px', color: 'black' }}>
                Add Note (Optional)
              </h4>
              <MedTextArea name="description" placeholder="Description" style={{ marginBottom: '40px' }} />
            </>
          )}
        </div>
      </SyncForm>
    </EuiFlexItem>
  );
};
