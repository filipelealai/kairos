import { randomUUID } from "node:crypto";

export type JobStatus = "running" | "done" | "failed";

export interface Job {
  id: string;
  status: JobStatus;
  startedAt: string;
  finishedAt: string | null;
  command: string;
  args: string[];
  cwd: string;
  stdout: string;
  stderr: string;
  exitCode: number | null;
  error: string | null;
}

const JOBS = new Map<string, Job>();
const MAX_JOBS = 50;

export function createJob(command: string, args: string[], cwd: string): Job {
  if (JOBS.size >= MAX_JOBS) {
    const oldest = [...JOBS.values()]
      .filter((j) => j.status !== "running")
      .sort((a, b) => a.startedAt.localeCompare(b.startedAt))[0];
    if (oldest) JOBS.delete(oldest.id);
  }
  const job: Job = {
    id: randomUUID(),
    status: "running",
    startedAt: new Date().toISOString(),
    finishedAt: null,
    command,
    args,
    cwd,
    stdout: "",
    stderr: "",
    exitCode: null,
    error: null,
  };
  JOBS.set(job.id, job);
  return job;
}

export function getJob(id: string): Job | undefined {
  return JOBS.get(id);
}

export function updateJob(id: string, patch: Partial<Job>): void {
  const job = JOBS.get(id);
  if (!job) return;
  Object.assign(job, patch);
}

export function listJobs(): Job[] {
  return [...JOBS.values()].sort((a, b) => b.startedAt.localeCompare(a.startedAt));
}
