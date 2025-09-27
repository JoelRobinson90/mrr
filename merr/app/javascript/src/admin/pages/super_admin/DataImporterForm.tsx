import React from 'react';
import { EuiFilePicker } from '@elastic/eui';
import { MedSelect } from '@/common/components/forms';
import { Controller, useFormContext } from 'react-hook-form';
import { DemandPartner } from './DataImporterPage';

export const ImportForm: React.FC<{
  name?: string;
  demandPartners?: Array<DemandPartner>;
  setActiveDemandPartner: Function;
  setCsvArray: Function;
  determineMissingFields: Function;
}> = ({ demandPartners, setActiveDemandPartner, setCsvArray, determineMissingFields }) => {
  const { control } = useFormContext();

  const demandPartnersOptions = demandPartners?.map((dp) => {
    return { value: dp.id, text: dp.name, id: dp.name };
  });

  const runModeOptions = [
    { value: 'Run in background', text: 'Run in background' },
    { value: 'Run in foreground', text: 'Run in foreground' },
  ];
  const importToOptions = [
    { value: 'medArrive', text: 'MedArrive & Kustomer (with AC background sync)' },
    { value: 'alayacare', text: 'Alayacare (for custom fields)' },
    { value: 'v2_import', text: 'MedArrive V2 (Salesforce + Athena)' },
  ];
  const updateMode = [
    { value: 'Create or Update', text: 'Create or Update' },
    { value: 'Update Only', text: 'Update Only' },
  ];

  const submit = (fileList, onChange) => {
    const file = fileList;
    if (file.length === 0) {
      setCsvArray([]);
    } else {
      const reader = new FileReader();
      reader.onload = function (e) {
        const text = e.target.result;
        processCSV(text);
      };
      reader.readAsText(file[0]);
      onChange(fileList);
    }
  };

  const processCSV = (str, delim = ',') => {
    const headers = str.slice(0, str.indexOf('\n')).split(delim);
    const rows = str.slice(str.indexOf('\n') + 1).split('\n');
    const trimmedHeaders = headers.map((h) => h.trim());
    const newArray = rows.map((row) => {
      const values = row.split(delim);
      const eachObject = trimmedHeaders.reduce((obj, header, i) => {
        obj[header] = values[i];
        return obj;
      }, {});
      return eachObject;
    });
    determineMissingFields(newArray);
    setCsvArray(newArray);
  };

  return (
    <>
      <div>
        <MedSelect aria-label="Run Mode" prepend="run_mode" name="run_mode" options={runModeOptions} />
        <MedSelect
          id={'demand_partner_select'}
          prepend="Demand Partner"
          name="demand_partner_id"
          options={demandPartnersOptions}
          onChange={(e) => setActiveDemandPartner(e)}
        />
        <MedSelect prepend="Update Mode" name="update_mode" options={updateMode} />
        <MedSelect prepend="Import To" name="import_to" options={importToOptions} />
      </div>
      <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', paddingLeft: 30, marginTop: 16 }}>
        <Controller
          style={{ height: '100%', marginTop: 16, width: '100%' }}
          name={'file'}
          control={control}
          render={({ onChange }) => {
            return (
              <EuiFilePicker
                fullWidth
                type="file"
                accept=".csv"
                id="a12sd3"
                initialPromptText="Select or drag and drop file"
                onChange={(e) => submit(e, onChange)}
                display={'default'}
              />
            );
          }}
        />
      </div>
    </>
  );
};
