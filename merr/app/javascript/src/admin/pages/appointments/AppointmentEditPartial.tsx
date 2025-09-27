import React from 'react';
import { useForm } from 'react-hook-form';
import {
  EuiFlyoutHeader,
  EuiButton,
  EuiButtonEmpty,
  EuiFlexGroup,
  EuiFlexItem,
  EuiFlyoutBody,
  EuiFlyoutFooter,
  EuiTitle,
} from '@elastic/eui';
import { SyncForm } from '@/common/components/SyncForm/SyncForm';
import { Appointment } from '@/common/types';
import { AppointmentForm } from '@/admin/pages/appointments/AppointmentForm/AppointmentForm';

type Props = {
  appointment: Appointment;
  available_tags: string[];
  onClose: () => void;
  redirectPath: string;
};

export const AppointmentEditPartial: React.FC<Props> = ({
  appointment,
  available_tags,
  onClose,
  redirectPath = '',
}) => {
  const { id, address, extra_vaccine_recipients } = appointment;

  const form = useForm({
    defaultValues: {
      appointment: {
        ...appointment,
        address_attributes: address,
        extra_vaccine_recipients_attributes: extra_vaccine_recipients,
      },
    },
  });

  const targetUrl = id ? `/admin/appointments/${id}` : `/admin/appointments`;
  const targetMethod = id ? 'put' : 'post';

  return (
    <>
      <EuiFlyoutHeader hasBorder>
        <EuiTitle size="m">
          <h2>Edit Appointment</h2>
        </EuiTitle>
      </EuiFlyoutHeader>

      <EuiFlyoutBody>
        <SyncForm form={form} url={targetUrl} method={targetMethod} id="appointmentEdit" requestRedirect={redirectPath}>
          <AppointmentForm appointment={appointment} available_tags={available_tags} showActions={false} />
        </SyncForm>
      </EuiFlyoutBody>

      <EuiFlyoutFooter>
        <EuiFlexGroup justifyContent="spaceBetween">
          <EuiFlexItem grow={false}>
            <EuiButtonEmpty iconType="cross" onClick={onClose} flush="left">
              Cancel
            </EuiButtonEmpty>
          </EuiFlexItem>
          <EuiFlexItem grow={false}>
            <EuiButton type="submit" form="appointmentEdit" className="appointmentEditSave" fill>
              Save
            </EuiButton>
          </EuiFlexItem>
        </EuiFlexGroup>
      </EuiFlyoutFooter>
    </>
  );
};
