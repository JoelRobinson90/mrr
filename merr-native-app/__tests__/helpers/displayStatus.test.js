import displayStatus from '../../src/helpers/displayStatus';

describe('displayStatus', () => {
  it('returns "In Progress" for status "clocked_in"', () => {
    expect(displayStatus('clocked')).toEqual('In Progress');
  });

  it('returns "Late" for status "late"', () => {
    expect(displayStatus('late')).toEqual('Late');
  });

  it('returns "Cancelled" for status "cancelled"', () => {
    expect(displayStatus('cancelled')).toEqual('Cancelled');
  });

  it('returns "Missed" for status "missed"', () => {
    expect(displayStatus('missed')).toEqual('Missed');
  });

  it('returns "Scheduled" for status "scheduled"', () => {
    expect(displayStatus('scheduled')).toEqual('Scheduled');
  });

  it('returns "Completed" for status "completed"', () => {
    expect(displayStatus('completed')).toEqual('Completed');
  });

  it('returns "En Route" for status "en_route"', () => {
    expect(displayStatus('en_route')).toEqual('En Route');
  });

  it('returns "On Site" for status "on_site"', () => {
    expect(displayStatus('on_site')).toEqual('On Site');
  });

  it('returns "Confirmed" for status "confirmed"', () => {
    expect(displayStatus('confirmed')).toEqual('Confirmed');
  });

  it('returns "No Status" for status null or ""', () => {
    expect(displayStatus(null)).toEqual('No Status');
    expect(displayStatus('')).toEqual('No Status');
  });

  it('returns the original status for unknown status values', () => {
    expect(displayStatus('unknown')).toEqual('unknown');
  });
});
