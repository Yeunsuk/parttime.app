import { WORKER_COLOR_PALETTE } from '../config.js';

// Dart의 workerId.hashCode.abs() % length와 동일 — 작은 정수는 Dart에서
// hashCode가 자기 자신이므로 그냥 절댓값 나머지로 계산하면 된다.
export function defaultWorkerColorIndex(workerId) {
  return Math.abs(workerId) % WORKER_COLOR_PALETTE.length;
}

export function colorForWorker(workerId, overrides) {
  const index = overrides?.[workerId] ?? defaultWorkerColorIndex(workerId);
  return WORKER_COLOR_PALETTE[index];
}
