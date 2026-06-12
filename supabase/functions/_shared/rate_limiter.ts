/**
 * Simple In-Memory Rate Limiter for Edge Functions
 * 
 * Note: Edge functions run in isolated environments (V8 isolates). This means
 * this rate limiter applies strictly per isolate, not globally across all regions.
 * For global rate limiting, a Redis store or Supabase DB table is recommended.
 */

interface RateLimitInfo {
  count: number;
  resetAt: number;
}

// Global scope for the isolate
const limits = new Map<string, RateLimitInfo>();

export const rateLimiter = {
  /**
   * Checks if a given identifier (e.g., userId or IP) is rate-limited.
   * @param identifier The unique key to rate limit on
   * @param maxRequests Maximum requests allowed in the window
   * @param windowMs Time window in milliseconds
   * @returns true if the request is allowed, false if rate-limited
   */
  check: (identifier: string, maxRequests: number = 5, windowMs: number = 60000): boolean => {
    const now = Date.now();
    const info = limits.get(identifier);

    // If no existing info or window has expired, reset
    if (!info || now > info.resetAt) {
      limits.set(identifier, {
        count: 1,
        resetAt: now + windowMs,
      });
      return true;
    }

    // Increment and check
    info.count++;
    if (info.count > maxRequests) {
      return false; // Rate limited
    }

    return true; // Allowed
  },
};
