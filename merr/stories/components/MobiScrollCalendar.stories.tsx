import React from 'react';
import { Story, Meta } from '@storybook/react';
import moment from 'moment';
import { FieldProvider } from '@/common/types';
import { MedEventcalendar } from '@/common/components/MedEventcalendar/MedEventcalendar';
import { MbscCalendarEventData, MbscResource } from '@mobiscroll/react';
import { MbscCalendarColor } from '@mobiscroll/react/dist/src/core/shared/calendar-view/calendar-view';
import { formatUtc } from '@/common/utils/dates/dates';

export default {
  title: 'Components/Eventcalendar',
  component: MedEventcalendar,
} as Meta;

const fieldProviders: Partial<FieldProvider>[] = [
  {
    id: 1,
    first_name: 'Michael',
  },
  {
    id: 2,
    first_name: 'Lauren',
  },
  {
    id: 3,
    first_name: 'Emma',
  },
];

const calendarResources: MbscResource[] = fieldProviders.map((fp) => ({
  id: fp.id,
  name: fp.first_name,
}));

const availabilities = [
  {
    id: 1,
    start: moment().set('h', 9).startOf('h'),
    end: moment().set('h', 18).startOf('h'),
  },
];

const calendarColors: MbscCalendarColor[] = availabilities.map((a) => ({
  ...a,
  background: '#CCFFCC',
}));

const calendarEvents: MbscCalendarEventData[] = [
  {
    startDate: moment().startOf('d').toDate(),
    start: formatUtc(moment().set('h', 10).startOf('h').set('m', 30).toDate()),
    endDate: moment().endOf('d').toDate(),
    end: formatUtc(moment().set('h', 12).startOf('h').set('m', 30).toDate()),
    color: '#FFCCCC',
    title: 'Appt1',
    resource: 1,
  },
];

const Template: Story = (args) => <MedEventcalendar {...args} />;

export const Default = Template.bind({});

Default.args = {
  view: {
    timeline: {
      type: 'week',
    },
  },
  resources: calendarResources,
  colors: calendarColors,
  data: calendarEvents,
};
