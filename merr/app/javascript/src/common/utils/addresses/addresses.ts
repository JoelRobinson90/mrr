import { Address } from '@/common/types';
import { compact } from 'lodash';

export const googleMapsUrl = (address: Address): string => {
  const addressWithoutLineTwo: Address = { ...address, address_line_two: null };
  const formatted = formattedAddressComponents(addressWithoutLineTwo).join(', ');
  const encoded = encodeURIComponent(formatted);
  return `https://www.google.com/maps/dir/?api=1&travelmode=driving&layer=traffic&destination=${encoded}`;
};

export const formattedAddressComponents = ({
  address_line_one,
  address_line_two,
  city,
  state,
  zipcode,
}: Address): string[] => compact([address_line_one, address_line_two, `${city}, ${state} ${zipcode}`]);
