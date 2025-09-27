import flatten from 'flat';
import { Dictionary, map, sortBy, isArray, isEmpty } from 'lodash';

export type OriginalSubmittedValues = Dictionary<string | string[] | FileList | unknown>;
type FormFieldPair = [string, string | FileList];

export type SubmitSyncFormOptions = {
  multipart?: boolean;
  requestRedirect?: string;
};

export const submitSyncForm = (
  url: string,
  method: string,
  values: OriginalSubmittedValues = {},
  options: SubmitSyncFormOptions = {},
) => {
  const form = createForm(url, method, options);
  const formValues = transformFormValues(values, options);
  const filteredValues = filterValues(formValues);
  populateFormInputs(form, filteredValues);
  submitForm(form);
};

// Creates a phantom form that will be submitted synchronously
const createForm = (url: string, method: string, options: Partial<SubmitSyncFormOptions>): HTMLFormElement => {
  const form = document.createElement('form');
  form.style.display = 'none';
  form.action = url;
  form.setAttribute('accept-charset', 'UTF-8');

  if (['get', 'post'].includes(method)) {
    form.method = method;
  } else {
    form.method = 'post';
    insertFieldInForm(form, ['_method', method]);
  }

  if (options.multipart) {
    form.setAttribute('enctype', 'multipart/form-data');
  }

  return form;
};

const filterValues = (values: FormFieldPair[]): FormFieldPair[] => {
  return values.filter((fieldPair) => typeof fieldPair[1] !== 'undefined');
};

// Transforms the object of values to a flat array of tuples with bracket-notated keys that
// Rails expects (i.e. `patient[first_name]`) and add authenticity_token for CSRF protection
const transformFormValues = (values: OriginalSubmittedValues, options: SubmitSyncFormOptions): FormFieldPair[] => {
  const csrfMetaTag = document.querySelector('[name=csrf-token]') as HTMLMetaElement;

  // Flatten nested object to get an object with dot-notated keys first (i.e. `patient.first_name`)
  const flattenedValues = flatten(values) as Dictionary<string>;

  // Transform to array of tuples since there may be duplicated key names at the end
  const flattenedPairs = map(flattenedValues, (val, key) => [key, val]);

  // Sort by key name to ensure field arrays stay grouped together
  const sortedFlattenedPairs = sortBy(flattenedPairs, (pair) => pair[0]);

  // Transform to the bracket notation that Rails expects (i.e. `patient[first_name]`)
  let newValues = sortedFlattenedPairs.map(([key, val]) => {
    // Specially handle empty arrays
    if (isArray(val) && isEmpty(val)) {
      return [dotToBracket(key), null] as FormFieldPair;
    }
    return [dotToBracket(key), val] as FormFieldPair;
  });

  const { requestRedirect } = options;
  if (requestRedirect) {
    newValues = [...newValues, ['request_redirect', requestRedirect]];
  }

  return [['authenticity_token', csrfMetaTag?.content], ...newValues];
};

// Creates a hidden input for each field and insert into the form
const populateFormInputs = (form: HTMLFormElement, pairs: FormFieldPair[]): void =>
  pairs.forEach((pair) => insertFieldInForm(form, pair));

// Submits the form synchronously
const submitForm = (form: HTMLFormElement): void => {
  document.body.appendChild(form);
  form.submit();
};

// Transforms dot-notated keys to bracket-notated keys and removes index numbers
// from array sets so Rails will read them properly
// i.e. `patient.foo_attributes.0.name` => `patient[foo_attributes][][name]`
const dotToBracket = (input: string): string =>
  input
    .split('.')
    .map((val, i) => (i === 0 ? val : `[${val}]`))
    .join('')
    .replace(/\[\d+\]/g, '[]');

const insertFieldInForm = (form: HTMLFormElement, [key, val]: FormFieldPair) => {
  const input = document.createElement('input');
  input.name = key;
  if (typeof val === 'object') {
    input.type = 'file';
    input.files = val;
  } else {
    input.type = 'hidden';
    input.value = val;
  }

  form.appendChild(input);
};
