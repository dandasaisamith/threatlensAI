import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.3";

import { corsHeaders } from "../_shared/cors.ts";
import { logger } from "../_shared/logger.ts";
import { rateLimiter } from "../_shared/rate_limiter.ts";
import { generateThreatModel } from "../_shared/llm.ts";
import { ThreatAnalysisRequest } from "../_shared/types.ts";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SUPABASE_ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
const LLM_API_KEY = Deno.env.get("LLM_API_KEY") ?? "";

serve(async (req: Request) => {
  // 1. Handle CORS preflight requests
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // 2. Validate Authentication
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      logger.warn("Missing Authorization header");
      return new Response(JSON.stringify({ error: "Missing Authorization header" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const supabaseClient = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
      global: { headers: { Authorization: authHeader } },
    });

    const { data: { user }, error: authError } = await supabaseClient.auth.getUser();

    if (authError || !user) {
      logger.warn("Unauthorized request", { error: authError?.message });
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // 3. Rate Limiting (10 requests per minute per user)
    const isAllowed = rateLimiter.check(user.id, 10, 60000);
    if (!isAllowed) {
      logger.warn(`Rate limit exceeded for user: ${user.id}`);
      return new Response(JSON.stringify({ error: "Too many requests. Please try again later." }), {
        status: 429,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // 4. Input Validation
    let requestData: ThreatAnalysisRequest;
    try {
      requestData = await req.json();
    } catch (e) {
      return new Response(JSON.stringify({ error: "Invalid JSON payload" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    if (!requestData.architectureDescription || typeof requestData.architectureDescription !== "string") {
      return new Response(JSON.stringify({ error: "Missing or invalid 'architectureDescription'" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    if (requestData.userId !== user.id) {
      logger.warn("User ID mismatch", { expected: user.id, provided: requestData.userId });
      return new Response(JSON.stringify({ error: "User ID mismatch" }), {
        status: 403,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    if (!LLM_API_KEY) {
      logger.error("LLM_API_KEY is not configured in Supabase Secrets");
      return new Response(JSON.stringify({ error: "Server configuration error" }), {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // 5. Invoke AI Service
    logger.info(`Starting threat analysis for user ${user.id}`);
    
    const startTime = Date.now();
    const threatModel = await generateThreatModel(requestData.architectureDescription, LLM_API_KEY);
    const latency = Date.now() - startTime;

    logger.info(`Threat analysis completed in ${latency}ms for user ${user.id}`);

    // 6. Return Typed Response
    return new Response(JSON.stringify(threatModel), {
      status: 200,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });

  } catch (error: any) {
    logger.error("Unhandled error in threat-analysis function", error);
    
    return new Response(JSON.stringify({ error: error.message || "Internal Server Error" }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
