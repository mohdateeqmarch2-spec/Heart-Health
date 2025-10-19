# PyVHR Real Heart Rate Analysis Setup

This guide will help you enable **real heart rate analysis** using PyVHR instead of simulated data.

## Current Status

Your app is currently using **simulated data** because the Python backend is not running. Follow these steps to enable real PyVHR analysis.

## Prerequisites

- Python 3.8 or higher
- pip3
- At least 2GB of free disk space (for ML dependencies)

## Step 1: Install Python Dependencies

Navigate to the python-backend directory and install dependencies:

```bash
cd python-backend
pip3 install -r requirements.txt
```

This will install:
- FastAPI (web framework)
- PyVHR (heart rate extraction from video)
- OpenCV (video processing)
- scikit-learn (ML risk prediction)
- NumPy, SciPy, Pandas (data processing)

## Step 2: Start the Python Backend

### Option A: Using the startup script (Recommended)

```bash
cd python-backend
./start.sh
```

### Option B: Manual start

```bash
cd python-backend
python3 -m uvicorn main:app --host 0.0.0.0 --port 8000
```

You should see output like:
```
============================================================
Starting Health Monitoring ML Backend
============================================================
Loading ML model and scaler...
✓ ML model loaded successfully
✓ PyVHR is available
============================================================
Backend initialization complete
============================================================
INFO:     Uvicorn running on http://0.0.0.0:8000
```

## Step 3: Verify Backend is Running

Open a browser or use curl to check the health endpoint:

```bash
curl http://localhost:8000/health
```

Expected response:
```json
{
  "status": "healthy",
  "service": "ml-backend",
  "components": {
    "pyvhr": {
      "available": true,
      "status": "OK"
    },
    "ml_model": {
      "loaded": true,
      "status": "Loaded",
      "type": "RandomForest"
    }
  }
}
```

## Step 4: Deploy the Updated Edge Function

Deploy the edge function with the updated code:

```bash
# The edge function has been updated with better logging
# It needs to be deployed to Supabase
```

Use the Supabase MCP tool to deploy:
- Function name: `process-heart-rate`
- The updated code is in `supabase/functions/process-heart-rate/index.ts`

## Step 5: Set Environment Variable (For Production)

If deploying to production, set the `PYTHON_BACKEND_URL` environment variable:

```bash
# For local development, it defaults to http://localhost:8000
# For production, set it to your Python backend URL
PYTHON_BACKEND_URL=https://your-backend-url.com
```

## How to Verify Real Analysis is Working

### 1. Check the Backend Logs

When processing a video, you should see in the Python backend terminal:

```
============================================================
[START] Processing video for recording_id: xxx
Video URL: https://...
============================================================
Checking PyVHR availability...
✓ PyVHR imported successfully
Processing video file: /tmp/xxx.webm
✓ PyVHR processing complete
Extracted 240 heart rate measurements
Average BPM: 72.45
✓ Successfully received real PyVHR analysis
============================================================
[SUCCESS] Analysis complete
============================================================
```

### 2. Check the Edge Function Logs

In Supabase dashboard, check the edge function logs. You should see:
```
✓ Successfully received real PyVHR analysis from Python backend
Heart rate data points: 240
```

### 3. Check the Response

The API response will include `"analysis_type": "pyvhr"` instead of `"simulated"`.

## Troubleshooting

### PyVHR Not Available

If you see "PyVHR not available, will use simulated data":

```bash
pip3 install pyVHR==2.0.0 opencv-python==4.8.1.78
```

### Video Download Fails

Ensure the video URL is publicly accessible. The Python backend needs to download the video file from Supabase storage.

### Backend Connection Refused

- Make sure the backend is running on port 8000
- Check if another service is using port 8000
- Verify firewall settings allow connections to port 8000

### Face Not Detected

PyVHR requires:
- Clear view of the face
- Good lighting conditions
- Minimal movement
- Video duration of at least 30 seconds
- Face must be visible throughout the recording

If PyVHR fails to detect a face or extract heart rate, the system will automatically fall back to simulated data.

## Performance Notes

- First request may be slow (model loading)
- Video processing takes 30-120 seconds depending on video length
- PyVHR requires significant CPU resources
- For production, consider using a dedicated server with GPU support

## Architecture

```
User Browser
    ↓
    Video Recording (WebRTC)
    ↓
Supabase Storage (video file)
    ↓
Supabase Edge Function
    ↓
Python Backend (FastAPI)
    ↓
PyVHR Analysis (real heart rate extraction)
    ↓
ML Model (RandomForest risk prediction)
    ↓
Results saved to Supabase Database
```

## What's Different from Simulation?

### Simulated Data:
- Uses mathematical sine wave patterns
- Random variations added
- No actual video analysis
- Instant results

### Real PyVHR Analysis:
- Analyzes actual blood volume pulse from facial video
- Uses computer vision to detect face ROI
- Extracts PPG signal from skin color changes
- Computes real HRV metrics (RMSSD, pNN50)
- Takes 30-120 seconds to process
- Requires good video quality

## Next Steps

Once PyVHR is working:
1. Test with different lighting conditions
2. Experiment with video duration (30-60 seconds recommended)
3. Compare results with a pulse oximeter for validation
4. Consider training the ML model on real clinical data
