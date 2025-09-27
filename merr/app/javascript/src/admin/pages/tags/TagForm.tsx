import { EuiButton, EuiButtonEmpty, EuiFlexGroup, EuiFlexItem } from '@elastic/eui';
import {
  MedSelect,
  MedTextField,
  MedColorPicker,
  InlineFormGroup,
  LeftField,
  RightField,
} from '@/common/components/forms';
import React from 'react';

interface TagFormProps {
  cancel: string;
}

export const TagForm: React.FC<TagFormProps> = ({ cancel }) => {
  return (
    <>
      <InlineFormGroup>
        <LeftField>Name</LeftField>
        <RightField>
          <MedTextField name="tag.name" />
        </RightField>
      </InlineFormGroup>
      <InlineFormGroup>
        <LeftField>Color</LeftField>
        <RightField>
          <MedColorPicker name="tag.color" />
        </RightField>
      </InlineFormGroup>
      <InlineFormGroup>
        <LeftField margin=" 15px auto auto">Description</LeftField>
        <RightField>
          <MedTextField name="tag.description" />
        </RightField>
      </InlineFormGroup>
      <InlineFormGroup>
        <LeftField>Group</LeftField>
        <RightField>
          <MedSelect
            name="tag.group"
            options={[
              { text: 'Appointment', value: 'Appointment' },
              { text: 'Patient', value: 'Patient' },
            ]}
          />
        </RightField>
      </InlineFormGroup>
      <EuiFlexGroup style={{ backgroundColor: '#f5f7fa', padding: '1rem', marginTop: '0' }}>
        <EuiFlexItem>
          <EuiButtonEmpty style={{ maxWidth: '153px' }} href={cancel} type="button">
            Cancel
          </EuiButtonEmpty>
        </EuiFlexItem>
        <EuiFlexItem style={{ alignItems: 'flex-end' }}>
          <EuiButton style={{ backgroundColor: '#00b38f', maxWidth: '153px', border: 'none' }} fill type="submit">
            Save
          </EuiButton>
        </EuiFlexItem>
      </EuiFlexGroup>
    </>
  );
};
