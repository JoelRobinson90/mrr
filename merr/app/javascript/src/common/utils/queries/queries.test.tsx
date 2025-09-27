import { getCurrentQuery, getUpdatedQueryPath } from './queries';

describe('queries utils', () => {
  const oldWindowLocation = window.location;

  beforeAll(() => {
    delete window.location;

    window.location = {
      ...oldWindowLocation,
      search: '?foo=bar',
      pathname: '/admin/path',
    };
  });

  afterAll(() => {
    window.location = oldWindowLocation;
  });

  describe('getCurrentQuery()', () => {
    it('returns an object with the current parsed query params', () => {
      expect(getCurrentQuery()).toEqual({ foo: 'bar' });
    });
  });

  describe('getUpdatedQueryPath()', () => {
    it('adds extra query params to the existing path', () => {
      expect(getUpdatedQueryPath({ med: 'arrive', page: 3 })).toEqual('/admin/path?foo=bar&med=arrive&page=3');
    });

    it('removes query params with null values', () => {
      expect(getUpdatedQueryPath({ foo: null, med: 'arrive' })).toEqual('/admin/path?med=arrive');
    });
  });
});
