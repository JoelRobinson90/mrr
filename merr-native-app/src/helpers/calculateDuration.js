import moment from 'moment-timezone';

const calculateDuration = (startTime, endTime) => moment(endTime).diff(moment(startTime), 'minutes');

export default calculateDuration;
