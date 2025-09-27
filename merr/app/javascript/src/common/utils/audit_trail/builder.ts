import { AuditEvent } from '@/common/components/AuditingList/AuditingList';
import { compact } from 'lodash';
import moment from 'moment';

const transformPaperTrailEventToEvent = (paperTrailEvent, id): AuditEvent => {
  if (!paperTrailEvent.length || compact(paperTrailEvent[1]).length === 0) {
    // skip if for some reason event is empty
    return null;
  }
  if (paperTrailEvent[0].includes('Note')) {
    return null;
  }
  // get date, specifically, everything before the second comma
  const formattedDate = paperTrailEvent[0].match(/^(?:[^,]*\,){2}/)[0];
  const date = moment(formattedDate, 'On dddd, D MMM YYYY at h:mm a ZZ,').utc();
  const username = paperTrailEvent[0].replace(formattedDate, '').replace(/(created|updated).*/, '');
  const event = paperTrailEvent[0]
    .replace(formattedDate, '')
    .replace(username, '')
    // remove model id. e.g [1] or [2]
    .replace(/(\[.*\])/, '')
    .replace(':', '');

  // dddd, D MMM YYYY, h:mm a
  return {
    type: 'event',
    item: {
      id: id,
      username: username,
      event: event,
      timestamp: date.format(),
      message: paperTrailEvent[1]?.join('\n'),
    },
  };
};

export const buildEventsList = (paper_trail = [], admin_notes = []): Array<AuditEvent> => {
  let events = [];
  events = [
    ...admin_notes?.map((item) => {
      return {
        type: 'note',
        item: {
          id: item.id,
          username: item.creator ? item.creator.display_name : 'System User',
          event: 'added a note',
          message: item.content,
          timestamp: item.created_at,
        },
      };
    }),
    ...paper_trail
      ?.map((item, index) => {
        return transformPaperTrailEventToEvent(item, index);
      })
      // filter out nulls
      .filter((x) => x),
  ];
  events = events.sort((a, b) => moment(b.item.timestamp).diff(moment(a.item.timestamp)));
  return events;
};
