import { buildAddress } from '@/../test_utils/factories';
import { formattedAddressComponents, googleMapsUrl } from './addresses';

describe('addresses utils', () => {
  describe('googleMapsUrl()', () => {
    it('returns a Google Maps directions link to the address without line two', () => {
      const address = buildAddress({
        display_name: 'should not be used',
        address_line_one: '123 Elm St',
        address_line_two: 'Apt 456',
        city: 'Miami',
        state: 'FL',
        zipcode: '33143',
      });
      expect(googleMapsUrl(address)).toEqual(
        'https://www.google.com/maps/dir/?api=1&travelmode=driving&layer=traffic&destination=123%20Elm%20St%2C%20Miami%2C%20FL%2033143',
      );
    });
  });

  describe('formattedAddressComponents', () => {
    it('returns an array of address components', () => {
      const address = buildAddress({
        address_line_one: '123 Elm St',
        address_line_two: 'Apt 456',
        city: 'Miami',
        state: 'FL',
        zipcode: '33143',
      });
      expect(formattedAddressComponents(address)).toEqual(['123 Elm St', 'Apt 456', 'Miami, FL 33143']);
    });

    it('skips address_line_two if not present', () => {
      const address = buildAddress({
        address_line_one: '123 Elm St',
        city: 'Miami',
        state: 'FL',
        zipcode: '33143',
      });
      expect(formattedAddressComponents(address)).toEqual(['123 Elm St', 'Miami, FL 33143']);
    });
  });
});
