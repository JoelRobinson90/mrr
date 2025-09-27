import { differenceInYears, parse } from 'date-fns';

export default function calculateAge(dob) {
  const age = differenceInYears(new Date(), parse(dob, 'yyyy-MM-dd', new Date()));
  return age;
}
