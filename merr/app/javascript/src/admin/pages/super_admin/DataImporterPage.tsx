import React, { FC, useState, useEffect } from 'react';
import {
  EuiTitle,
  EuiPageContent,
  EuiPageContentHeader,
  EuiButton,
  EuiFlexGroup,
  EuiFlexItem,
  EuiSpacer,
  EuiText,
  EuiCallOut,
} from '@elastic/eui';
import { AdminLayout, AdminPageProps } from '@/admin/components/AdminLayout/AdminLayout';
import { useForm } from 'react-hook-form';
import { SyncForm } from '@/common/components/SyncForm/SyncForm';
import { ImportTable } from './DataImporterTable';
import { ImportForm } from './DataImporterForm';
import { FieldStatusTable } from './FieldStatusTable';

export type Result = {
  created_at: string;
  error_list: string[];
  id: string;
  job_type: string;
  label: string;
  message: string;
  status: string;
};

export type Klass = {
  data: {
    attributes: {
      properties: {};
    };
  };
};

export type DemandPartner = {
  id: string;
  name: string;
};

export type DemandPartnerCustomField = {
  demand_partner_id: string;
  csv_column_name: string;
  crm_field_name: string;
  ehr_field_name: string;
};

interface DataImporterPageProps extends AdminPageProps {
  import_results: Result[];
  queue_size: number;
  queue_errors: number;
  demand_partners: { id: string; name: string }[];
  demand_partner_custom_fields?: DemandPartnerCustomField[];
  general_fields: string[];
  klasses: Klass;
  isProduction: boolean;
}

export const DataImporterPage: FC<DataImporterPageProps> = ({
  layout_props,
  import_results,
  queue_size,
  queue_errors,
  demand_partners,
  demand_partner_custom_fields,
  general_fields,
  klasses,
  isProduction,
}) => {
  const [activeDemandPartner, setActiveDemandPartner] = useState({ id: '', name: '' });
  const [csvArray, setCsvArray] = useState([]);
  const [missingMAFields, setMissingMAFields] = useState([]);

  const fileForm = useForm({
    defaultValues: {
      file: {
        file: {},
      },
      import_to: '',
    },
  });

  useEffect(() => {
    determineMissingFields();
  }, [activeDemandPartner]);

  // gets fed into the form so on change we can know what the dp is
  const setActiveDemandPartnerProxy = (e) => {
    const demandPartner = demand_partners.find((dp) => dp.id == e.target.value);
    setActiveDemandPartner({ id: e.target.value, name: demandPartner.name });
  };

  const demand_partner_specific_fields = demand_partner_custom_fields.filter((dpcf) => {
    return dpcf?.demand_partner_id?.toString() === activeDemandPartner.id && dpcf?.demand_partner_id;
  });

  const fields_across_demand_partners = demand_partner_custom_fields.filter((dpcf) => {
    return !dpcf?.demand_partner_id;
  });

  // This is complicated since we're getting fields from multiple sources.
  // Moving all fields to the DPCF table will simplify this considerably
  const determineMissingFields = (newCsvArray = csvArray) => {
    // if there's no csv, don't bother here; everything is missing
    if (newCsvArray.length === 0) {
      return;
    }

    const holder = [];

    // get the column names and make 'em lowercase
    const csvColumns = Object.keys(newCsvArray[0]).map((column) => column.toLowerCase());

    /* addMissingDPCFields == "addMissingDemandPartnerCustomFields", as in the fields in the table;
    This is a helper function specific to this larger function */
    const addMissingDPCFields = (field) => {
      if (csvColumns.includes(field.csv_column_name.trim()) === false) {
        holder.push(field.csv_column_name);
      }
    };

    demand_partner_specific_fields.forEach((field) => {
      addMissingDPCFields(field);
    });

    fields_across_demand_partners.forEach((field) => {
      addMissingDPCFields(field);
    });

    general_fields.forEach((field) => {
      if (!csvColumns.includes(field)) {
        holder.push(field);
      }
    });

    holder.sort();
    setMissingMAFields(holder);
  };

  const environmentBanner = () => {
    return isProduction ? (
      <EuiCallOut
        style={{ display: 'flex', flexDirection: 'row', justifyContent: 'center' }}
        title="IMPORTING TO PROD"
        color="danger"
      />
    ) : (
      <EuiCallOut
        style={{ display: 'flex', flexDirection: 'row', justifyContent: 'center' }}
        title="NOT IMPORTING TO PROD"
        color="success"
      />
    );
  };

  return (
    <AdminLayout {...layout_props}>
      <EuiText>
        <EuiPageContent>
          {environmentBanner()}
          <EuiPageContentHeader>
            <EuiTitle>
              <h2>Import</h2>
            </EuiTitle>
          </EuiPageContentHeader>
          <EuiSpacer size="m" />
          <div style={{ display: 'flex', flexDirection: 'row', justifyContent: 'space-between' }}>
            <SyncForm form={fileForm} url={`/data_import/data_import`} method="post" multipart>
              <EuiFlexGroup style={{ alignItems: 'flex-start', flexDirection: 'column' }}>
                <EuiFlexItem grow={2}>
                  <EuiSpacer />
                  <EuiSpacer />
                  <ImportForm
                    demandPartners={demand_partners}
                    setActiveDemandPartner={setActiveDemandPartnerProxy}
                    setCsvArray={setCsvArray}
                    determineMissingFields={determineMissingFields}
                  />
                </EuiFlexItem>
                <EuiFlexItem>
                  <EuiButton type="submit">
                    Import <b>{csvArray.length}</b> patients
                  </EuiButton>
                </EuiFlexItem>
              </EuiFlexGroup>
            </SyncForm>
          </div>

          <EuiSpacer />
          <div style={{ display: 'flex', flexDirection: 'row', justifyContent: 'space-around' }}>
            <FieldStatusTable
              platform="medarrive"
              missingMAFields={missingMAFields}
              activeDemandPartner={activeDemandPartner}
              csvArray={csvArray}
              general_fields={general_fields}
              demand_partner_specific_fields={demand_partner_specific_fields}
              fields_across_demand_partners={fields_across_demand_partners}
            />
            <FieldStatusTable
              platform="kustomer"
              missingMAFields={missingMAFields}
              activeDemandPartner={activeDemandPartner}
              csvArray={csvArray}
              demand_partner_specific_fields={demand_partner_specific_fields}
              fields_across_demand_partners={fields_across_demand_partners}
              klasses={klasses}
            />
            <FieldStatusTable
              platform="alayacare"
              missingMAFields={missingMAFields}
              activeDemandPartner={activeDemandPartner}
              csvArray={csvArray}
              demand_partner_specific_fields={demand_partner_specific_fields}
              fields_across_demand_partners={fields_across_demand_partners}
            />
          </div>

          <div
            style={{ fontSize: 42, justifyContent: 'center', display: 'flex', flexDirection: 'row', paddingBottom: 20 }}
          >
            Recent Imports
          </div>
          <a href="/delayed_job/overview">
            {queue_size} items queued. {queue_errors} queue errors.
          </a>
          <ImportTable import_results={import_results} />
        </EuiPageContent>
      </EuiText>
    </AdminLayout>
  );
};
