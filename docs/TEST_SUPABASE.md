# 🧪 Supabase Test Guide

## Quick Test Steps

### 1. Open Xcode
```bash
cd "/Users/enesarikan/Desktop/Projects/ENES ARIKAN - appstore/Ancient World Stories"
open "Ancient World Stories.xcodeproj"
```

### 2. Run the App
- Press **⌘R** or click the Play button
- Wait for the app to launch in the simulator

### 3. Check Console Output

Open the console with **⌘⇧Y** and look for:

#### ✅ Success Message
```
✅ Successfully loaded 3 civilizations, 3 stories, and 30 chapters from Supabase
```

#### ⚠️ Fallback Message (if Supabase fails)
```
⚠️ Supabase failed, loading from local JSON
Error: [error details]
```

---

## 📱 Test Each Feature

### Home Tab
- [ ] App opens to Home tab
- [ ] Shows "Random Chapters" section
- [ ] Displays chapter cards with titles
- [ ] Can tap on a chapter to open reader

### Explore Tab
- [ ] Tap "Explore" tab at bottom
- [ ] See 3 civilizations listed:
  - Ancient Mesopotamia
  - Ancient Egypt
  - Ancient Greece
- [ ] Tap on a civilization
- [ ] See the story for that civilization
- [ ] Tap on the story
- [ ] See all chapters listed

### Reader View
- [ ] Tap on any chapter
- [ ] Chapter text displays correctly
- [ ] Play button appears at bottom
- [ ] Tap play to start TTS
- [ ] Audio plays the chapter text
- [ ] Can pause/resume playback

---

## 🔍 Verify Data

### Check Civilizations
In Explore tab, you should see:

1. **Ancient Mesopotamia**
   - Era: 3500 BC - 539 BC
   - Region: Middle East
   - Story: "The Scribe of Uruk"

2. **Ancient Egypt**
   - Era: 3100 BC - 30 BC
   - Region: North Africa
   - Story: "Pharaoh's Dream"

3. **Ancient Greece**
   - Era: 800 BC - 146 BC
   - Region: Mediterranean
   - Story: "The Oracle's Vision"

### Check Chapter Counts
- The Scribe of Uruk: **12 chapters**
- Pharaoh's Dream: **10 chapters**
- The Oracle's Vision: **8 chapters**

---

## 🐛 Common Issues

### Issue: "Supabase failed" in console

**Possible Causes:**
1. No internet connection
2. Supabase project is paused (free tier inactivity)
3. API credentials are incorrect

**Solutions:**
1. Check internet connection
2. Visit [Supabase Dashboard](https://supabase.com/dashboard) and ensure project is active
3. Verify `Configuration.swift` has correct URL and key

---

### Issue: App crashes on launch

**Check:**
1. Build succeeded without errors
2. Simulator is running
3. Check console for error messages

---

### Issue: No chapters appear

**Check:**
1. Console message - is data loading?
2. If using Supabase, verify tables have data
3. If using local JSON, check `stories.json` exists

---

## 🧪 Manual API Test

Test the Supabase API directly in your browser:

### Test Civilizations Endpoint
```
https://njpjehnphsceepechadv.supabase.co/rest/v1/civilizations?select=*
```

Add this header in Postman or curl:
```
apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5qcGplaG5waHNjZWVwZWNoYWR2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIwMDk5MTEsImV4cCI6MjA3NzU4NTkxMX0.deAvavILAyoKDFR9K3Rw5FwO_lJ1r7_GKoE9WHjiVx0
```

Expected response:
```json
[
  {
    "id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
    "name": "Ancient Mesopotamia",
    "era_start": "3500 BC",
    "era_end": "539 BC",
    "region": "Middle East",
    "description": "The cradle of civilization..."
  },
  ...
]
```

---

## ✅ Success Checklist

- [ ] App launches without crashes
- [ ] Console shows "Successfully loaded from Supabase"
- [ ] 3 civilizations appear in Explore tab
- [ ] Each civilization has a story
- [ ] Stories have correct chapter counts (12, 10, 8)
- [ ] Can open and read any chapter
- [ ] TTS plays audio correctly
- [ ] Navigation works smoothly

---

## 📊 Performance Check

### Expected Load Times
- Initial launch: < 2 seconds
- Supabase data fetch: < 1 second
- Chapter navigation: Instant
- TTS initialization: < 1 second

### Memory Usage
- Should stay under 100MB
- No memory leaks during navigation

---

## 🎉 If Everything Works

**Congratulations!** Your app is:
- ✅ Connected to cloud backend
- ✅ Loading real data from Supabase
- ✅ Ready for production
- ✅ Has offline fallback
- ✅ Fully functional

**Next Steps:**
1. Add more content via Supabase Dashboard
2. Test on real device
3. Prepare for App Store submission
4. Consider adding user accounts (Supabase Auth)
5. Add analytics to track usage

---

## 📞 Need Help?

If you encounter issues:
1. Check console output for detailed errors
2. Verify Supabase Dashboard shows data
3. Test API endpoints manually
4. Review `SUPABASE_SETUP_COMPLETE.md` for configuration details
