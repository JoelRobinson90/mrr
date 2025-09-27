import React from 'react';
import { Story, Meta } from '@storybook/react';

import { MedComboBox, MedComboBoxProps } from '@/common/components/forms';
import { SyncForm } from '@/common/components/SyncForm/SyncForm';
import { useForm } from 'react-hook-form';

export default {
  title: 'Components/Form Fields/MedComboBox',
  component: MedComboBox,
  argTypes: {},
} as Meta;

type ExtraProps = {
  initialValue: number[];
};

const Template: Story<MedComboBoxProps & ExtraProps> = ({ initialValue, ...props }) => {
  const form = useForm({
    defaultValues: {
      [props.name]: initialValue,
    },
  });

  return (
    // @ts-ignore
    <SyncForm url="/" form={form} disabled>
      <MedComboBox {...props} />
    </SyncForm>
  );
};

export const Default = Template.bind({});
Default.args = {
  name: 'tag_ids',
  label: 'Tags',
  options: [
    { value: 1, label: 'Tag 1' },
    { value: 2, label: 'Tag 2' },
    { value: 3, label: 'Tag 3' },
  ],
  initialValue: [1, 3],
} as MedComboBoxProps & ExtraProps;
