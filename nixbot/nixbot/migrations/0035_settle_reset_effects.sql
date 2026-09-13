-- Rows an earlier ResetBuildForRestart put back to pending on builds that
-- then re-finished on a gated ref: nothing owns them any more.
DELETE FROM effect_runs r
USING builds b
WHERE r.build_id = b.id AND r.owner = 'build' AND r.status = 'pending'
  AND b.status IN ('succeeded', 'failed', 'cancelled')
  AND NOT EXISTS (
    SELECT 1 FROM work_queue w
    WHERE w.kind = 'effect' AND w.status IN ('pending', 'running')
      AND (w.payload->>'build_id')::bigint = r.build_id
      AND w.payload->>'kind' = r.kind AND w.payload->>'name' = r.name);
