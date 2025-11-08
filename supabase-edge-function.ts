// Supabase Edge Function: minimax-tts
// Copy this entire file and paste into Supabase Dashboard → Edge Functions

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const FAL_API_KEY = Deno.env.get('FAL_AI_API_KEY')!
const FAL_ENDPOINT = 'https://fal.run/fal-ai/minimax/speech-2.6-turbo'

serve(async (req) => {
  // CORS headers for preflight
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

    console.log(`🎙️ TTS Request: ${text.substring(0, 50)}... (voice: ${voice_id || 'Wise_Woman'})`)

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
      const errorText = await response.text()
      console.error(`❌ Fal AI API error: ${response.status} - ${errorText}`)
      throw new Error(`Fal AI API error: ${response.statusText}`)
    }

    const data = await response.json()

    console.log(`✅ TTS generated: ${data.audio?.url ? 'success' : 'no audio URL'}`)

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
    console.error(`❌ Error: ${error.message}`)
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
