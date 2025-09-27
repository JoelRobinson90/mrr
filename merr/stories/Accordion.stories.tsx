import { MedTextField } from '@/common/components/forms';
import {
  EuiAccordion,
  EuiAccordionProps,
  EuiButton,
  EuiFlexGroup,
  EuiFlexItem,
  EuiFormRow,
  EuiHorizontalRule,
  EuiHorizontalRuleProps,
  EuiText,
} from '@elastic/eui';
import { Meta } from '@storybook/react';
import React from 'react';
import { FormProvider, useForm } from 'react-hook-form';

export default {
  title: 'Components/EuiAccordion',
  component: EuiAccordion,
} as Meta;

export const PatientEditAccordion = () => {
  const accordionPadding: EuiAccordionProps['paddingSize'] = 'l';
  const horizontalRuleMargin: EuiHorizontalRuleProps['margin'] = 'm';

  const form = useForm({
    defaultValues: {
      patient: {
        date_of_birth: '11/23/1989',
      },
    },
  });

  return (
    <div>
      <EuiHorizontalRule margin={horizontalRuleMargin} />

      <EuiAccordion
        id="patient.id"
        paddingSize={accordionPadding}
        buttonContent={
          <p>
            <strong>Patient ID:</strong> 12345678910
          </p>
        }
      >
        <EuiText>
          <p>Content inside accordion</p>
        </EuiText>
      </EuiAccordion>

      <EuiHorizontalRule margin={horizontalRuleMargin} />

      <EuiAccordion
        id="patient.full_name"
        paddingSize={accordionPadding}
        buttonContent={
          <EuiText>
            <strong>Patient name:</strong> Sandra V. Martinez
          </EuiText>
        }
      >
        <EuiText>
          <p>Content inside accordion</p>
        </EuiText>
      </EuiAccordion>

      <EuiHorizontalRule margin={horizontalRuleMargin} />

      <EuiAccordion
        id="patient.full_name"
        paddingSize={accordionPadding}
        buttonContent={
          <EuiText>
            <strong>Patient email:</strong> sandra_martinez89@gmail.com
          </EuiText>
        }
      >
        <EuiText>
          <p>Content inside accordion</p>
        </EuiText>
      </EuiAccordion>

      <EuiHorizontalRule margin={horizontalRuleMargin} />

      <EuiAccordion
        id="patient.date_of_birth"
        initialIsOpen
        paddingSize={accordionPadding}
        buttonContent={
          <EuiText>
            <strong>Patient&#39;s date of birth is:</strong> 11/23/1989
          </EuiText>
        }
      >
        <FormProvider {...form}>
          <EuiFlexGroup>
            <EuiFlexItem grow={4}>
              <EuiText size="s" color="subdued">
                Description text that might normally be in help text but fits better underneath the humanized input
                title.
              </EuiText>
            </EuiFlexItem>
            <EuiFlexItem grow={2}>
              <MedTextField name="patient.date_of_birth" label="Date of Birth:" />
            </EuiFlexItem>
            <EuiFlexItem grow={1}>
              <EuiFormRow hasEmptyLabelSpace>
                <EuiButton color="secondary" fill fullWidth>
                  Save
                </EuiButton>
              </EuiFormRow>
            </EuiFlexItem>
          </EuiFlexGroup>
        </FormProvider>
      </EuiAccordion>

      <EuiHorizontalRule margin={horizontalRuleMargin} />

      <EuiAccordion
        id="patient.full_address"
        paddingSize={accordionPadding}
        buttonContent={
          <EuiText>
            <strong>Patient&#39;s address is:</strong> 9712 Valdez Dr. Urbandale, Iowa 50322
          </EuiText>
        }
      >
        <EuiText>
          <p>Content inside accordion</p>
        </EuiText>
      </EuiAccordion>

      <EuiHorizontalRule margin={horizontalRuleMargin} />

      <EuiAccordion
        id="patient.phone_number"
        paddingSize={accordionPadding}
        buttonContent={
          <EuiText>
            <strong>Patient&#39;s phone number is:</strong> 515-710-3171
          </EuiText>
        }
      >
        <EuiText>
          <p>Content inside accordion</p>
        </EuiText>
      </EuiAccordion>

      <EuiHorizontalRule margin={horizontalRuleMargin} />
    </div>
  );
};
