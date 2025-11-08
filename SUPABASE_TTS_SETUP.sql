-- Supabase Edge Function Setup for Minimax TTS
-- This keeps the Fal AI API key secure on the server side

-- No database tables needed - Edge Function will handle API key securely
-- The API key should be stored as a Supabase secret, not in the database

-- To set up the Edge Function:
-- 1. Go to Supabase Dashboard → Edge Functions
-- 2. Create new function named: 'minimax-tts'
-- 3. Add secret: FAL_AI_API_KEY = 5e273259-94de-4902-b148-902bfbf4571f:df6051fa08db3c6e98bd97dca8585118
-- 4. Deploy the function code below

/*
Edge Function Code (TypeScript):

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const FAL_API_KEY = Deno.env.get('FAL_AI_API_KEY')!
const FAL_ENDPOINT = 'https://fal.run/fal-ai/minimax/speech-2.6-turbo'

serve(async (req) => {
  // CORS headers
  if (req.method === 'OPTIONS') {
    return new Response('ok', {
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST',
        'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
      }
    })
  }

  try {
    const { text, voice_id, speed, language } = await req.json()

    // Validate input
    if (!text || text.length === 0) {
      throw new Error('Text is required')
    }

    // Call Fal AI Minimax API
    const response = await fetch(FAL_ENDPOINT, {
      method: 'POST',
      headers: {
        'Authorization': `Key ${FAL_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        prompt: text,
        voice_setting: {
          voice_id: voice_id || 'Wise_Woman',
          speed: speed || 1.0,
          vol: 1,
          pitch: 0,
          emotion: 'neutral'
        },
        audio_setting: {
          sample_rate: 24000,
          bitrate: 128000,
          format: 'mp3'
        },
        output_format: 'url',
        language_boost: language || 'en'
      })
    })

    if (!response.ok) {
      throw new Error(`Fal AI API error: ${response.statusText}`)
    }

    const data = await response.json()

    return new Response(
      JSON.stringify({
        audio_url: data.audio?.url,
        duration_ms: data.duration_ms
      }),
      {
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        }
      }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        status: 400,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        }
      }
    )
  }
})
*/

-- Usage Instructions:
-- 1. Deploy the Edge Function to Supabase
-- 2. Get the function URL (e.g., https://YOUR_PROJECT.supabase.co/functions/v1/minimax-tts)
-- 3. Use this URL in your iOS app instead of calling Fal AI directly
-- 4. This keeps the API key secure on the server side

-- Example iOS request:
/*
let url = URL(string: "https://YOUR_PROJECT.supabase.co/functions/v1/minimax-tts")!
var request = URLRequest(url: url)
request.httpMethod = "POST"
request.setValue("application/json", forHTTPHeaderField: "Content-Type")
request.setValue("YOUR_SUPABASE_ANON_KEY", forHTTPHeaderField: "apikey")

let payload: [String: Any] = [
    "text": "Hello world!",
    "voice_id": "Wise_Woman",
    "speed": 1.0,
    "language": "en"
]
request.httpBody = try JSONSerialization.data(withJSONObject: payload)
*/
