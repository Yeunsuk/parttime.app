import { api } from '../api.js';

export const workRecordApi = {
  getStatus() {
    return api.get('/work-records/status');
  },
  clockIn(workplaceId) {
    return api.post('/work-records/clock-in', { workplaceId });
  },
  clockOut(recordId) {
    return api.patch(`/work-records/${recordId}/clock-out`);
  },
  getCalendar(year, month) {
    return api.get('/work-records/calendar', { year, month });
  },
};
