// Supabase Edge Function: gemini-proxy
//
// Why this exists at all: the Gemini API key is billable. Calling Gemini
// directly from Flutter web would mean compiling the key into the JS
// bundle, where anyone can read it out of dev tools. This function is the
// only thing that ever sees the real key — it lives as a Supabase Edge
// Function secret (`supabase secrets set GEMINI_API_KEY=...`), not as a
// --dart-define value, and never as part of the Flutter build.
//
// Deploy once with: supabase functions deploy gemini-proxy
// Set the secret once with: supabase secrets set GEMINI_API_KEY=your-key
//
// The Flutter side calls this via supabase.functions.invoke('gemini-proxy',
// ...) — see lib/services/gemini_service.dart — which automatically
// attaches the signed-in user's auth token, so this function can trust
// req.headers has a valid Supabase JWT (Supabase's Edge Runtime verifies
// it before this code even runs, as long as `verify_jwt` isn't disabled).

import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';

const GEMINI_API_KEY = Deno.env.get('GEMINI_API_KEY');
const GEMINI_ENDPOINT =
  'https://generativelanguage.googleapis.com/v1beta/models/gemini-3.8-flash:generateContent';

// Low thinking level = the cheapest tier Gemini 3 models support for this
// model ('minimal' is rejected by gemini-3.8-flash specifically). Neither
// of this app's two use cases (a yes/no classification, and summarizing a
// week of already-structured log data) needs deep multi-step reasoning,
// so 'low' is a deliberate token-minimizing choice, not a default left
// untouched.
const THINKING_LEVEL = 'low';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
};

async function callGemini(prompt: string, maxOutputTokens: number) {
  const res = await fetch(`${GEMINI_ENDPOINT}?key=${GEMINI_API_KEY}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      contents: [{ parts: [{ text: prompt }] }],
      generationConfig: {
        thinkingConfig: { thinkingLevel: THINKING_LEVEL },
        maxOutputTokens,
      },
    }),
  });

  if (!res.ok) {
    const errText = await res.text();
    throw new Error(`Gemini API error ${res.status}: ${errText}`);
  }

  const data = await res.json();
  const text: string | undefined =
    data?.candidates?.[0]?.content?.parts?.[0]?.text;
  if (text === undefined) {
    throw new Error('Gemini response had no text (possibly hit maxOutputTokens on thinking).');
  }
  return text;
}

function buildValidatePrompt(input: string): string {
  // Deliberately tiny: one instruction, one input, one-word answer
  // requested. Every extra sentence here is extra input tokens on every
  // single meal/drink log — this prompt is called far more often than the
  // weekly analysis one, so it's the one most worth keeping lean.
  return (
    'Reply with exactly one word, YES or NO. Is this a real food or drink ' +
    `item a person could plausibly eat or drink? Input: "${input}"`
  );
}

function buildAnalyzePrompt(payload: {
  heightCm: number;
  weightKg: number;
  food: { mealType: string; description: string; loggedAt: string }[];
  drinks: { description: string; amountMl: number | null; loggedAt: string }[];
  sleep: { durationHours: number; date: string }[];
  exercise: { durationMinutes: number; date: string }[];
}): string {
  // Structured input, structured output requested — keeps the model from
  // padding its answer with conversational filler, which is the other
  // real lever on output tokens besides thinkingLevel.
  return `You are analyzing one week of health-tracking data for a user
(height ${payload.heightCm}cm, weight ${payload.weightKg}kg).

Food logged: ${JSON.stringify(payload.food)}
Drinks logged: ${JSON.stringify(payload.drinks)}
Sleep per day (hours): ${JSON.stringify(payload.sleep)}
Exercise per day (minutes): ${JSON.stringify(payload.exercise)}

Reply with ONLY valid JSON, no markdown fences, no extra text, matching
exactly this shape:
{
  "dailySummaryText": "1-2 sentence summary of today specifically",
  "weeklyTrends": {"sleep": "↑ 12%", "activity": "→ Stable", "water": "↓ 8%"},
  "suggestions": [
    {"emoji": "💧", "title": "short title", "description": "one sentence"}
  ]
}
Give exactly 3 suggestions, each grounded in the actual data above (e.g. if
sleep is consistently low, say so specifically) — do not invent generic
advice unconnected to the numbers given.`;
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const { action, payload } = await req.json();

    if (action === 'validate') {
      const text = await callGemini(
        buildValidatePrompt(payload.input),
        // 'low' thinking still spends a couple hundred tokens reasoning
        // before answering (this is a Gemini 3 model — thinking can't be
        // fully disabled), so this needs headroom above "just enough for
        // one word" or the response gets cut off before the answer.
        300,
      );
      const isValid = text.trim().toUpperCase().startsWith('YES');
      return new Response(JSON.stringify({ isValid }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    if (action === 'analyze') {
      const text = await callGemini(buildAnalyzePrompt(payload), 1200);
      // Defensive: strip markdown fences if the model adds them anyway.
      const cleaned = text.trim().replace(/^```json\s*|```$/g, '').trim();
      const parsed = JSON.parse(cleaned);
      return new Response(JSON.stringify(parsed), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    return new Response(JSON.stringify({ error: 'Unknown action' }), {
      status: 400,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  } catch (err) {
    return new Response(JSON.stringify({ error: String(err) }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
