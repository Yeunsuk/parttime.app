import { api } from '../api.js';

export const workplaceApi = {
  getMyWorkplaces() {
    return api.get('/workplaces/my');
  },
  create(name, hourlyWage) {
    return api.post('/workplaces', { name, hourlyWage });
  },
  join(inviteCode) {
    return api.post('/workplaces/join', { inviteCode });
  },
  getWorkers(workplaceId) {
    return api.get(`/workplaces/${workplaceId}/workers`);
  },
  updateMemberLimit(workplaceId, memberLimit) {
    return api.patch(`/workplaces/${workplaceId}/member-limit`, { memberLimit });
  },
  updateDisabledHours(workplaceId, disabledHours) {
    return api.patch(`/workplaces/${workplaceId}/disabled-hours`, { disabledHours });
  },
  updateEnabledMinutes(workplaceId, enabledMinutes) {
    return api.patch(`/workplaces/${workplaceId}/enabled-minutes`, { enabledMinutes });
  },
  addMember(workplaceId, employeeId) {
    return api.post(`/workplaces/${workplaceId}/members`, { email: employeeId });
  },
  removeMember(workplaceId, workerId) {
    return api.delete(`/workplaces/${workplaceId}/members/${workerId}`);
  },
  updateDefaultTime(workplaceId, workerId, clockInHour, clockInMinute, clockOutHour, clockOutMinute) {
    return api.patch(`/workplaces/${workplaceId}/members/${workerId}/default-time`, {
      clockInHour,
      clockInMinute,
      clockOutHour,
      clockOutMinute,
    });
  },
  updatePayPeriod(workplaceId, workerId, payPeriodStartDay) {
    return api.patch(`/workplaces/${workplaceId}/members/${workerId}/pay-period`, { payPeriodStartDay });
  },
  updatePaymentType(workplaceId, workerId, paymentType) {
    return api.patch(`/workplaces/${workplaceId}/members/${workerId}/payment-type`, { paymentType });
  },
  updateWorkingDays(workplaceId, workerId, enabled, days) {
    return api.patch(`/workplaces/${workplaceId}/members/${workerId}/working-days`, { enabled, days });
  },
};
