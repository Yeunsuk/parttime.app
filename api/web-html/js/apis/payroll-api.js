import { api } from '../api.js';

export const payrollApi = {
  getWorkplaceRecords(workplaceId, year, month) {
    return api.get(`/workplaces/${workplaceId}/records`, { year, month });
  },
  getWorkerDetail(workplaceId, workerId, year, month) {
    return api.get(`/workplaces/${workplaceId}/workers/${workerId}/records`, { year, month });
  },
  modifyRecord(recordId, clockIn, clockOut) {
    return api.patch(`/work-records/${recordId}/modify`, { clockIn, clockOut });
  },
  addRecord(workplaceId, workerId, clockIn, clockOut, recordCount) {
    const body = { clockIn, clockOut };
    if (recordCount !== undefined && recordCount !== null) body.recordCount = recordCount;
    return api.post(`/workplaces/${workplaceId}/workers/${workerId}/records`, body);
  },
  deleteRecord(recordId) {
    return api.delete(`/work-records/${recordId}`);
  },
  getSettlement(workplaceId, year, month) {
    return api.get(`/workplaces/${workplaceId}/settlement`, { year, month });
  },
};
