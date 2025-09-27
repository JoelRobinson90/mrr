import { FieldProvider } from '@/common/types';
import { EuiFlexGroup, EuiFlexItem, EuiFormRow, EuiButton } from '@elastic/eui';
import React, { useEffect, useRef } from 'react';
import { useForm } from 'react-hook-form';
import styled from 'styled-components';
import { MedComboBox } from '../forms';
import { SyncForm } from '../SyncForm/SyncForm';

const StyledComboBox = styled(MedComboBox)`
  min-width: 300px;
  margin-top: 1.4rem;
`;

interface Props {
  submitUrl: string;
  fieldName?: string;
  formMethod?: string;
  fieldProviders: FieldProvider[];
  submitButtonLabel?: string;
  selectedFieldProvider?: FieldProvider;
  triggerOnChange?: boolean;
}

export const FieldProviderAssigner: React.FC<Props> = ({
  submitUrl,
  fieldName = 'field_provider_id',
  formMethod = 'post',
  fieldProviders,
  submitButtonLabel,
  selectedFieldProvider,
  triggerOnChange = false,
}) => {
  const mountRef = useRef(true);
  const refSubmitButtom = useRef<HTMLButtonElement>(null);
  const form = useForm({
    defaultValues: {
      [fieldName]: selectedFieldProvider?.id,
    },
  });

  // @TODO: This was causing an issue on appointment view, all submit buttons where submitting this form.
  // Check the reason behind this and add more tests.
  // useEffect(() => {
  //   // skip first time render
  //   if (mountRef.current) return;
  //   // if triggerOnChange enable submit the form manually
  //   if (triggerOnChange) refSubmitButtom?.current?.click();
  // }, [fieldProviderValue]);

  useEffect(() => {
    mountRef.current = false;
  }, []);

  const fieldProviderOptions = fieldProviders.map((fp) => ({
    value: fp.id,
    label: fp.display_name,
  }));
  return (
    <SyncForm form={form} url={submitUrl} method={formMethod}>
      <EuiFlexGroup style={{ maxWidth: 600 }}>
        <EuiFlexItem>
          <StyledComboBox
            data-test-id={fieldName}
            fullWidth
            width="100%"
            name={fieldName}
            options={fieldProviderOptions}
            placeholder="Choose a field provider..."
            singleSelection={{ asPlainText: true }}
          />
        </EuiFlexItem>
        {!triggerOnChange && submitButtonLabel && (
          <EuiFlexItem>
            <EuiFormRow hasEmptyLabelSpace>
              <EuiButton fill color="secondary" type="submit">
                {submitButtonLabel}
              </EuiButton>
            </EuiFormRow>
          </EuiFlexItem>
        )}
        <button hidden={true} ref={refSubmitButtom} type="submit" />
      </EuiFlexGroup>
    </SyncForm>
  );
};
