// 앱 전역 상태. Flutter의 authStateProvider/selectedWorkplaceIdProvider에 대응한다.
// selectedWorkplaceId는 근무지가 2개 이상일 때 사용자가 고른 값 — 새로고침하면 잊혀도
// 된다(Flutter 쪽도 "in-memory only, not persisted"로 동일하게 동작).
export const state = {
  currentUser: null, // { id, email, name, role }
  selectedWorkplaceId: null,
};

// workplaces가 1개면 그것을, 2개 이상이면 selectedId와 일치하는 것을 반환한다.
// 없거나 아직 선택되지 않았으면 null(선택 UI를 보여줘야 한다는 뜻).
export function resolveWorkplace(workplaces, selectedId) {
  if (!workplaces || workplaces.length === 0) return null;
  if (workplaces.length === 1) return workplaces[0];
  return workplaces.find((w) => w.id === selectedId) || null;
}
