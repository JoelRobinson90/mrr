import { differenceInYears } from 'date-fns';
import calculateAge from '../../src/helpers/calculateAge';

jest.mock('date-fns');

describe('calculateAge', () => {
  it('calculates the age correctly', () => {
    differenceInYears.mockReturnValueOnce(23);
    expect(calculateAge('2000-01-01')).toEqual(23);
  });
});
