import React from 'react';
import moment from 'moment';
import { Meta } from '@storybook/react';
import {
  EuiAccordion,
  EuiAccordionProps,
  EuiBadge,
  EuiButton,
  EuiButtonEmpty,
  EuiComboBox,
  EuiComboBoxOptionOption,
  EuiFormRow,
  EuiFlexGroup,
  EuiFlexItem,
  EuiIcon,
  EuiPanel,
  EuiSpacer,
  EuiText,
} from '@elastic/eui';

export default {
  title: 'Components/WorkLists/WorkListItem',
  component: EuiAccordion,
} as Meta;

type Patient = {
  name: string;
  partner: string;
};

type Service = {
  name: string;
};

type WorkListItem = {
  id: string;
  patient: Patient;
  created_at: string;
  worklist_status: string;
  disposition_status: string;
  services: Service[];
};

// Rails created_at example: '2021-01-28 12:36:56' -> formatDate('2021-01-28 12:36:56') returns `2 days ago`
const getDays = (date) => moment(date, 'YYYYMMDD').fromNow();

// returns `January 28th, 2021`
const formatDate = (dateStr: string): string => moment(dateStr).format('MMMM Do, YYYY');

const createButtonContent = (patientName: string): JSX.Element => (
  <div>
    <EuiFlexGroup gutterSize="s" alignItems="center" responsive={false}>
      <EuiFlexItem grow={false}>
        <EuiIcon type="alert" size="m" color="danger" />
      </EuiFlexItem>
      <EuiFlexItem grow={false}>
        <EuiText size="m" className="euiAccordionForm__title">
          <p>
            <strong>{patientName}</strong> &nbsp;&nbsp;&nbsp; worklist disposition description
          </p>
        </EuiText>
      </EuiFlexItem>
    </EuiFlexGroup>
  </div>
);

const createExtraAction = ({ created_at, disposition_status, worklist_status }) => (
  <div>
    <EuiFlexGroup gutterSize="s" alignItems="center" responsive={false}>
      <EuiFlexItem grow={false}>
        <EuiText>
          <em>{getDays(created_at).replace('ago', 'old')}</em>
        </EuiText>
      </EuiFlexItem>
      <EuiFlexItem grow={false}>
        <EuiFlexGroup>
          <EuiFlexItem grow={false}>
            <EuiBadge iconType="clock" color="hollow">
              {disposition_status}
            </EuiBadge>
          </EuiFlexItem>
          <EuiFlexItem grow={false}>
            <EuiBadge color="#DD0A73"> {worklist_status}</EuiBadge>
          </EuiFlexItem>
        </EuiFlexGroup>
      </EuiFlexItem>
    </EuiFlexGroup>
  </div>
);

const services = [
  { name: 'Phlebotomy' },
  { name: 'Nutrition' },
  { name: 'Pharmaceutical' },
  { name: 'Dentistry' },
  { name: 'Oncology' },
];
const patients = [
  {
    name: 'Sandra Martinez',
    partner: 'Millenium Physician Group',
  },
  {
    name: 'Janice Graycie',
    partner: 'Millenium Physician Group',
  },
  {
    name: 'Javier Rallo',
    partner: 'Millenium Physician Group',
  },
  {
    name: 'Nola Savianic',
    partner: 'Millenium Physician Group',
  },
  {
    name: 'Roland Dougla',
    partner: 'Millenium Physician Group',
  },
];

// this function creates labels from services object to allow for proper matching into EuiComboBoxProps
const createOptions = (services: Service[]): Array<EuiComboBoxOptionOption> =>
  services.map(({ name }) => ({ label: name }));

const accordionPadding: EuiAccordionProps['paddingSize'] = 'l';
const WorkListItemAccordion: React.FC<WorkListItem> = ({
  patient,
  disposition_status,
  created_at,
  services,
  worklist_status,
}): JSX.Element => (
  <EuiPanel>
    <EuiAccordion
      id="accordionWithExtraRightArrow"
      paddingSize={accordionPadding}
      buttonContent={createButtonContent(patient.name)}
      arrowDisplay="right"
      extraAction={createExtraAction({ disposition_status, created_at, worklist_status })}
    >
      <div>
        <EuiText grow={false} size="m">
          <p>
            This member was added {getDays(created_at)} on {formatDate(created_at)} via {patient.partner}. There are
            probably
            <EuiSpacer size="s" />
            other details that need to be described here, but I&#39;m really not sure what they are yet.
          </p>
        </EuiText>
        <br />
        <br />
        <div>
          <EuiFormRow
            label={'Add Services'}
            helpText={
              "Select all services that apply from the list. If a service you are looking for isn't available, please contact us"
            }
          >
            <EuiComboBox options={createOptions(services)} selectedOptions={[createOptions(services)[0]]} />
          </EuiFormRow>
        </div>
      </div>
      <EuiSpacer size="m" />
      <EuiSpacer size="m" />
      <EuiFlexGroup justifyContent="spaceBetween" gutterSize="s" component="div" direction="row">
        <EuiFlexItem grow={false}>
          <EuiFlexGroup>
            <EuiFlexItem grow={false}>
              <EuiIcon type="cross" onClick={() => alert('Close button clicked')} />
            </EuiFlexItem>
            <EuiFlexItem grow={false}>
              <p>Close</p>
            </EuiFlexItem>
          </EuiFlexGroup>
        </EuiFlexItem>
        <EuiFlexItem grow={false}>
          <EuiFlexGroup>
            <EuiFlexItem grow={false}>
              <EuiButtonEmpty onClick={() => alert('View patient button clicked')}>View Patient</EuiButtonEmpty>
            </EuiFlexItem>
            <EuiFlexItem grow={false}>
              <EuiButton color="secondary" size="m" fill onClick={() => alert('Save button clicked')}>
                Save
              </EuiButton>
            </EuiFlexItem>
          </EuiFlexGroup>
        </EuiFlexItem>
      </EuiFlexGroup>
    </EuiAccordion>
  </EuiPanel>
);

const workListItems = [
  {
    services,
    id: '1',
    patient: patients[0],
    disposition_status: 'Disposition',
    worklist_status: 'Needing Services',
    created_at: '2021-01-28 12:36:56',
  },
  {
    services,
    id: '2',
    patient: patients[1],
    disposition_status: 'Disposition',
    worklist_status: 'Needing Services',
    created_at: '2021-01-28 12:36:56',
  },
  {
    services,
    id: '3',
    patient: patients[2],
    disposition_status: 'Disposition',
    worklist_status: 'Needing Services',
    created_at: '2021-01-28 12:36:56',
  },
  {
    services,
    id: '4',
    patient: patients[3],
    disposition_status: 'Disposition',
    worklist_status: 'Needing Services',
    created_at: '2021-01-28 12:36:56',
  },
  {
    services,
    id: '5',
    patient: patients[4],
    disposition_status: 'Disposition',
    worklist_status: 'Needing Services',
    created_at: '2021-01-28 12:36:56',
  },
];

// export the `WorkListItemsAccordion` just for demo purposes
export const WorkListItemsAccordion = () => (
  <div>
    {workListItems.map((worklistItem) => {
      return (
        <div key={worklistItem.id}>
          <WorkListItemAccordion {...worklistItem} />
          <EuiSpacer size="s" />
        </div>
      );
    })}
  </div>
);
