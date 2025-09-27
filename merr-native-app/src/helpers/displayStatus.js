export default function displayStatus(status) {
  switch (status) {
    case 'clocked':
      return 'In Progress';
    case 'late':
      return 'Late';
    case 'cancelled':
      return 'Cancelled';
    case 'missed':
      return 'Missed';
    case 'scheduled':
      return 'Scheduled';
    case 'completed':
      return 'Completed';
    case 'en_route':
      return 'En Route';
    case 'on_site':
      return 'On Site';
    case 'confirmed':
      return 'Confirmed';
    case null:
      return 'No Status';
    case '':
      return 'No Status';
    default:
      return status;
  }
}
