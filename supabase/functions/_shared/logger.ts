type Level = 'debug' | 'info' | 'warn' | 'error';

export interface CidLogger {
  cid: string;
  debug: (msg: string, meta?: Record<string, unknown>) => void;
  info: (msg: string, meta?: Record<string, unknown>) => void;
  warn: (msg: string, meta?: Record<string, unknown>) => void;
  error: (msg: string, meta?: Record<string, unknown>) => void;
}

function emit(level: Level, fn: string, cid: string, msg: string, meta?: Record<string, unknown>) {
  const line = {
    t: new Date().toISOString(),
    level,
    fn,
    correlation_id: cid,
    msg,
    ...(meta ?? {}),
  };
  const output = JSON.stringify(line);
  if (level === 'error') console.error(output);
  else if (level === 'warn') console.warn(output);
  else console.log(output);
}

export function makeLogger(fn: string, cid: string): CidLogger {
  return {
    cid,
    debug: (message, meta) => emit('debug', fn, cid, message, meta),
    info: (message, meta) => emit('info', fn, cid, message, meta),
    warn: (message, meta) => emit('warn', fn, cid, message, meta),
    error: (message, meta) => emit('error', fn, cid, message, meta),
  };
}
