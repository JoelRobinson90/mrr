/* eslint-disable camelcase */
import React from 'react';
import PropTypes from 'prop-types';
import calculateAge from '../helpers/calculateAge';

import DisplayRow from './DisplayRow';

export default function PatientDetails({ visit, actionsAllowed = true }) {
  const {
    date_of_birth,
    sex,
    preferred_language,
    phone_number,
    contact_email,
    address,
  } = visit?.patient || {};

  const addressLineOneWithoutNumber = address?.address_line_one
    .split(' ')
    .slice(1)
    .join(' ');
  return (
    <>
      <DisplayRow label="Age" value={calculateAge(date_of_birth)} />
      <DisplayRow label="Sex" value={sex} />
      <DisplayRow label="Preferred Language" value={preferred_language} />
      <DisplayRow label="Phone" value={phone_number} />
      <DisplayRow label="Email" value={contact_email} />
      <DisplayRow
        label="Address"
        value={`${
          actionsAllowed
            ? address?.address_line_one
            : addressLineOneWithoutNumber
        } ${address?.address_line_two || ''}`}
      />
      <DisplayRow
        label="City/State"
        value={`${address?.city}, ${address?.state}`}
      />
      {/* <DisplayRow label="Phone" value={phone_number} /> */}
    </>
  );
}

PatientDetails.propTypes = {
  visit: PropTypes.shape({
    patient: PropTypes.shape(),
  }).isRequired,
};
