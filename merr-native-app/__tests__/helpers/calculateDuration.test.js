import moment from 'moment-timezone';
import calculateDuration from '../../src/helpers/calculateDuration';

describe('calculateDuration', () => {
  const time = new Date();
  const startTime = moment(time);
  const startTimeNull = null;
  const endTimeNull = null;

  it('calculates duration correctly for starTime and endTime', () => {
    const endTime = moment(time);
    endTime.add(moment.duration(1, 'hours'));
    const result = calculateDuration(startTime, endTime);
    expect(result).toEqual(60);
  });

  it('calculating duration correctly for the same hour in startTtime and endTime', () => {
    const endTime = moment(time);
    const result = calculateDuration(startTime, endTime);
    expect(result).toEqual(0);
  });

  it('calculate duration with start Time and without end Time', () => {
    const result = calculateDuration(startTime, endTimeNull);
    expect(result).toEqual(NaN);
  });

  it('calculate duration without start Time and with end Time', () => {
    const endTime = moment(time);
    const result = calculateDuration(startTimeNull, endTime);
    expect(result).toEqual(NaN);
  });
});
