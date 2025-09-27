import formatVisitProviders from '../../src/helpers/formatVisitProviders';

describe('formatVisitProviders', () => {
  it('formats visit providers correctly', () => {
    const providers = [
      { first_name: 'John', last_name: 'Doe', role: 'nurse' },
      { first_name: 'Jane', last_name: 'Smith', role: 'physician' },
      { first_name: 'Bob', last_name: 'Johnson', role: 'nurse' },
    ];

    const expectedOutput = [
      { name: 'John Doe', label: 'Nurse' },
      { name: 'Jane Smith', label: 'Physician' },
      { name: 'Bob Johnson', label: 'Nurse' },
    ];

    expect(formatVisitProviders(providers)).toEqual(expectedOutput);
  });

  it('returns an empty array when no providers are passed', () => {
    expect(formatVisitProviders([])).toEqual([]);
  });
});
