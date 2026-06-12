import { ThreatAnalysisResponse } from "./types.ts";
import { logger } from "./logger.ts";

const DEEPSEEK_API_URL = "https://api.deepseek.com/v1/chat/completions";
const MODEL = "deepseek-chat";

// System prompt to enforce strict JSON structure
const SYSTEM_PROMPT = `
You are a top-tier cybersecurity architect and threat modeler.
You will receive an architecture description of a software system.
You MUST output a detailed threat model exactly matching the JSON structure below.
Do not wrap your response in markdown code blocks, output ONLY valid JSON.

Required JSON Structure:
{
  "assets": [
    {
      "id": "uuid-v4-string",
      "name": "string",
      "description": "string",
      "type": "data|hardware|software|service",
      "sensitivity": "low|medium|high|critical"
    }
  ],
  "threats": [
    {
      "id": "uuid-v4-string",
      "assetId": "uuid-of-associated-asset",
      "title": "string",
      "description": "string",
      "strideCategory": "spoofing|tampering|repudiation|information_disclosure|denial_of_service|elevation_of_privilege",
      "status": "pending|mitigated|accepted|in_progress"
    }
  ],
  "dreadScores": [
    {
      "threatId": "uuid-of-associated-threat",
      "damage": 1-10,
      "reproducibility": 1-10,
      "exploitability": 1-10,
      "affectedUsers": 1-10,
      "discoverability": 1-10
    }
  ],
  "mitigations": [
    {
      "id": "uuid-v4-string",
      "threatId": "uuid-of-associated-threat",
      "description": "string",
      "priority": "low|medium|high|critical",
      "status": "planned|implemented|verified|rejected"
    }
  ]
}
`;

/**
 * Fetches threat analysis from DeepSeek with timeout and retry logic
 */
export async function generateThreatModel(
  architectureDescription: string,
  apiKey: string,
): Promise<ThreatAnalysisResponse> {
  const maxRetries = 3;
  const timeoutMs = 45000; // 45 seconds

  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), timeoutMs);

    try {
      logger.info(`Invoking DeepSeek API (Attempt ${attempt}/${maxRetries})...`);

      const response = await fetch(DEEPSEEK_API_URL, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Authorization": `Bearer ${apiKey}`,
        },
        body: JSON.stringify({
          model: MODEL,
          messages: [
            { role: "system", content: SYSTEM_PROMPT },
            { role: "user", content: `Analyze the following architecture and generate a threat model:\n\n${architectureDescription}` }
          ],
          response_format: { type: "json_object" }, // Enforce JSON
          temperature: 0.2, // Low temperature for consistent output
        }),
        signal: controller.signal,
      });

      clearTimeout(timeoutId);

      if (!response.ok) {
        throw new Error(`DeepSeek API Error: ${response.status} ${response.statusText}`);
      }

      const rawJson = await response.json();
      const content = rawJson.choices?.[0]?.message?.content;

      if (!content) {
        throw new Error("No content returned from DeepSeek");
      }

      // Parse and roughly validate
      const parsed = JSON.parse(content) as ThreatAnalysisResponse;
      
      if (!parsed.assets || !parsed.threats || !parsed.dreadScores || !parsed.mitigations) {
        throw new Error("DeepSeek response missing required top-level arrays");
      }

      logger.info("Successfully generated threat model", {
        assetsCount: parsed.assets.length,
        threatsCount: parsed.threats.length,
        tokensUsed: rawJson.usage?.total_tokens,
      });

      return parsed;
    } catch (error: any) {
      clearTimeout(timeoutId);

      logger.warn(`Attempt ${attempt} failed: ${error.message}`);

      if (error.name === "AbortError") {
        logger.warn("Request timed out");
      }

      if (attempt === maxRetries) {
        throw new Error(`Failed to generate threat model after ${maxRetries} attempts: ${error.message}`);
      }

      // Exponential backoff: 2s, 4s
      const backoffMs = Math.pow(2, attempt) * 1000;
      await new Promise((resolve) => setTimeout(resolve, backoffMs));
    }
  }

  throw new Error("Unexpected end of DeepSeek invocation loop");
}
