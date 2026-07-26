# Ancient World Stories — Ideas & Notes

## Feature ideas

### High priority
- **Offline download + real narration packs** — Paywall already promises “immersive audio”; system TTS is a start, pro voice packs are a stronger premium hook.
- **Home Screen Widget: Daily Story** — Cheap retention win; resurfaces the free daily chapter.
- **Reading reminder (local push)** — Soft nudge before the streak breaks.

### Medium priority
- **AI “Ask the Historian”** — Short Q&A at the end of a chapter for engagement and re-reads.
- **Continue Reading card on Home** — One tap back to the last unfinished chapter.
- **Localized story content (TR / DE / …)** — UI supports ~15 languages; bundle content is still mostly English.

### Nice to have
- **Family Sharing / gift a free week** — Viral / referral growth.
- **Listen mode (lock screen + Now Playing)** — Better for walking / commute use.
- **Wire real analytics** (Mixpanel / Amplitude) — Onboarding → paywall → purchase funnel is currently blind.

## Recently fixed (context)
- Profile / read progress now loads on launch
- RevenueCat race on paywall softened
- Collections no longer reshuffle every render
- Daily Story only picks free (order 1) chapters
- Empty-content infinite loading → error + retry
- Basic TTS via `AVSpeechSynthesizer` in the reader
- Reading Path copy localized
- Explore map zoom + empty time-travel guard
- Civilizations sorted by real `startYear`
