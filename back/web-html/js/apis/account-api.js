import { api } from '../api.js';

export const accountApi = {
  getAccounts(workplaceId) {
    return api.get(`/workplaces/${workplaceId}/accounts`);
  },
  create(workplaceId, accountName, accountNumber, bankName) {
    return api.post(`/workplaces/${workplaceId}/accounts`, { accountName, accountNumber, bankName });
  },
  addQr(workplaceId, accountId, name, qrImage) {
    return api.post(`/workplaces/${workplaceId}/accounts/${accountId}/qrs`, { name, qrImage });
  },
  deleteQr(workplaceId, accountId, qrId) {
    return api.delete(`/workplaces/${workplaceId}/accounts/${accountId}/qrs/${qrId}`);
  },
  delete(workplaceId, accountId) {
    return api.delete(`/workplaces/${workplaceId}/accounts/${accountId}`);
  },
};
