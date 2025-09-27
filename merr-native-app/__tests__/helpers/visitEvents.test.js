import getRecentVisitEvent from '../../src/helpers/visitEvents';

describe('getRecentVisitEvent', () => {
  it('should return the most recent visit event', () => {
    const visit = {
      visit_events: [
        { event_type: 'on_site', time: '2023-04-10T23:07:42.898Z' },
        { event_type: 'in_progress', time: '2023-04-11T01:07:42.898Z' },
      ],
    };
    const recentEvent = getRecentVisitEvent(visit);
    expect(recentEvent).toEqual({ event_type: 'in_progress', time: '2023-04-11T01:07:42.898Z' });
  });

  it('should return null if the visit has no events', () => {
    const visit = {};
    const recentEvent = getRecentVisitEvent(visit);
    expect(recentEvent).toBeNull();
  });
});
