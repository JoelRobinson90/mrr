const getRecentVisitEvent = (visit) => {
  if (visit?.visit_events?.length) {
    const recent = [...visit.visit_events].reduce((a, b) => (a.time > b.time ? a : b));
    return recent;
  }
  return null;
};

export default getRecentVisitEvent;
