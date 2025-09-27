import { AlayacareVisit } from '@/common/types';
import { EuiLink } from '@elastic/eui';
import React, { FC } from 'react';

import { admin_patient_path, field_patient_path } from '@/common/routes';

interface VisitPopupActionsProps {
  visit: AlayacareVisit;
  isAdmin: Boolean;
  visitGroup: any;
}

export const PatientLinks: FC<VisitPopupActionsProps> = ({ isAdmin, visitGroup, visit }) => {
  let link;

  if (isAdmin) {
    link = admin_patient_path;
  } else {
    link = field_patient_path;
  }

  if (visitGroup?.visits && visitGroup?.visits[0]?.patient?.first_name) {
    return visitGroup?.visits.map((v) => (
      <EuiLink
        key={v?.patient?.id}
        href={link(v?.patient?.id)}
      >{`${v.patient?.first_name} ${v.patient?.last_name}`}</EuiLink>
    ));
  }
  return (
    <EuiLink key={visit?.patient?.id} href={link(visit?.patient?.id)}>
      {visit.patient?.first_name} {visit.patient?.last_name}
    </EuiLink>
  );
};
