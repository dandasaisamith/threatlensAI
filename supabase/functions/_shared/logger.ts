/**
 * Structured JSON Logger for Edge Functions
 */

export enum LogLevel {
  INFO = "INFO",
  WARN = "WARN",
  ERROR = "ERROR",
  DEBUG = "DEBUG",
}

interface LogPayload {
  message: string;
  level: LogLevel;
  [key: string]: any;
}

export const logger = {
  log: (payload: LogPayload) => {
    // Avoid logging sensitive PII or raw tokens
    const safePayload = { ...payload };
    if (safePayload.token) delete safePayload.token;
    if (safePayload.password) delete safePayload.password;
    if (safePayload.authorization) delete safePayload.authorization;

    // Structured JSON output
    console.log(JSON.stringify({
      timestamp: new Date().toISOString(),
      ...safePayload,
    }));
  },

  info: (message: string, context?: Record<string, any>) => {
    logger.log({ message, level: LogLevel.INFO, ...context });
  },

  warn: (message: string, context?: Record<string, any>) => {
    logger.log({ message, level: LogLevel.WARN, ...context });
  },

  error: (message: string, error?: any, context?: Record<string, any>) => {
    const errorDetails = error instanceof Error 
      ? { errorName: error.name, errorMessage: error.message, stack: error.stack }
      : { error };
    logger.log({ message, level: LogLevel.ERROR, ...errorDetails, ...context });
  },
};
