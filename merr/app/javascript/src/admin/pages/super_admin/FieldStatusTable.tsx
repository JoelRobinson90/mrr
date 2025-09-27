import React, { FC } from 'react';
import { EuiPanel, EuiText, EuiSpacer, EuiAccordion } from '@elastic/eui';
import { DemandPartnerCustomField, Klass } from './DataImporterPage';

interface FieldStatusTable {
  activeDemandPartner?: any;
  missingMAFields?: string[];
  csvArray?: any[];
  platform: string;
  general_fields?: string[];
  demand_partner_specific_fields?: DemandPartnerCustomField[];
  fields_across_demand_partners?: DemandPartnerCustomField[];
  klasses?: Klass;
}

export const FieldStatusTable: FC<FieldStatusTable> = ({
  missingMAFields,
  activeDemandPartner,
  csvArray,
  platform,
  general_fields,
  demand_partner_specific_fields,
  fields_across_demand_partners,
  klasses,
}) => {
  let platformFieldName = '';
  if (platform === 'alayacare') {
    platformFieldName = 'ehr_field_name';
  } else if (platform === 'kustomer') {
    platformFieldName = 'crm_field_name';
  } else {
    platformFieldName = 'csv_column_name';
  }

  const displayPresentFields = (fieldSubset) => {
    let display = [];
    fieldSubset.forEach((field) => {
      if (!missingMAFields.includes(field.csv_column_name) && field[platformFieldName] && csvArray.length > 0) {
        display.push(field.csv_column_name);
      }
    });
    return display.map((d) => <div key={`presentDpcf${platform}${activeDemandPartner.name}${d}`}>{d}</div>);
  };

  const displayAbsentDemandPartnerSpecificCustomFields = () => {
    let display = [];

    demand_partner_specific_fields.forEach((field) => {
      const dpcfDpAndActiveDpMatch = field.demand_partner_id.toString() === activeDemandPartner.id.toString();

      if (csvArray.length === 0 && field[platformFieldName] && dpcfDpAndActiveDpMatch) {
        display.push(field.csv_column_name);
      } else if (
        missingMAFields.includes(field.csv_column_name) &&
        field[platformFieldName] &&
        dpcfDpAndActiveDpMatch
      ) {
        display.push(field.csv_column_name);
      }
    });
    return display.map((d) => <div key={`absentDpcf${platform}${activeDemandPartner.name}${d}`}>{d}</div>);
  };

  const displayAbsentCustomFields = () => {
    let display = [];
    fields_across_demand_partners.forEach((field) => {
      // no csv and there's and that dpcf has a value for this platform means it's missing
      if (csvArray.length === 0 && field[platformFieldName]) {
        display.push(field.csv_column_name);
      } else {
        if (missingMAFields.includes(field.csv_column_name) === true && field[platformFieldName]) {
          display.push(field.csv_column_name);
        }
      }
    });
    return display.map((d) => <div key={`AbsentField${platform}${d}`}>{d}</div>);
  };

  // These "hardcoded" functions will go away when all fields are moved to the DPCF table
  const displayPresentHardcodedFields = (field) => {
    if (missingMAFields.includes(field) === false && csvArray.length > 0) {
      if (field === 'demand_partner' || field === 'medical_record_number') {
        return `${field}*`;
      }
      return field;
    }
  };

  // These "hardcoded" functions will go away when all fields are moved to the DPCF table
  const displayAbsentHardcodedFields = (field) => {
    if (missingMAFields.includes(field) || csvArray.length === 0) {
      if (field === 'demand_partner' || field === 'medical_record_number') {
        return `${field}*`;
      }
      return field;
    }
  };

  // Once everything moves to the DPCF table, it'll be easy to display these fields; before then it doesn't seem worth the hassle
  const noteText =
    'Note: hardcoded fields (such as "first_name") are currently ommited from this column but are imported to this platform';

  return (
    <EuiText>
      <div style={{ display: 'flex', flexDirection: 'row' }}>
        <div style={{ width: '100%', display: 'flex', flexDirection: 'column', paddingLeft: 50 }}>
          <h2 style={{ textTransform: 'capitalize' }}>{platform} Columns</h2>
          {platform === 'alayacare' && noteText}
          {platform === 'kustomer' && noteText}
          <EuiSpacer />
          <div
            style={{
              width: '100%',
              maxWidth: 800,
              display: 'flex',
              flexDirection: 'row',
              justifyContent: 'space-around',
            }}
          >
            <EuiPanel grow={false}>
              <EuiText>
                <h3>General fields present</h3>
                {platform === 'medarrive' &&
                  general_fields.map((field) => (
                    <div key={`presentField${field}`}>{displayPresentHardcodedFields(field)}</div>
                  ))}
                {displayPresentFields(fields_across_demand_partners)}
              </EuiText>
              <EuiSpacer />
              <EuiText>
                <h3>General fields absent</h3>
                {platform === 'medarrive' &&
                  general_fields.map((field) => <div key={field}>{displayAbsentHardcodedFields(field)}</div>)}
                {displayAbsentCustomFields()}
                <EuiSpacer />
                <div>
                  <b>* required</b>
                </div>
              </EuiText>
            </EuiPanel>
            <EuiPanel grow={false}>
              <EuiText>
                <h3>{activeDemandPartner.name ? activeDemandPartner.name : 'DP'} custom fields present</h3>
                {displayPresentFields(demand_partner_specific_fields)}
              </EuiText>
              <EuiSpacer />
              <EuiText>
                <h3>{activeDemandPartner.name ? activeDemandPartner.name : 'DP'} fields absent</h3>
                {displayAbsentDemandPartnerSpecificCustomFields()}
              </EuiText>
            </EuiPanel>
          </div>
        </div>
      </div>

      {klasses && klasses.data && (
        <div
          style={{
            width: '100%',
            maxWidth: 800,
            display: 'flex',
            flexDirection: 'row',
            justifyContent: 'space-around',
            paddingTop: 10,
          }}
        >
          <EuiSpacer />
          <EuiAccordion id={'123'} buttonContent="Available Kustomer Klasses">
            <EuiPanel color="subdued">
              {Object.keys(klasses.data.attributes.properties)
                .sort()
                .map((k) => (
                  <div key={k}>{k}</div>
                ))}
            </EuiPanel>
          </EuiAccordion>
        </div>
      )}
    </EuiText>
  );
};
