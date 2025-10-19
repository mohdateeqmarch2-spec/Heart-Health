#!/bin/bash

echo "=========================================="
echo "Health Monitoring Python Backend Startup"
echo "=========================================="
echo ""

if ! command -v python3 &> /dev/null; then
    echo "ERROR: Python 3 is not installed"
    exit 1
fi

echo "Python version: $(python3 --version)"
echo ""

if ! command -v pip3 &> /dev/null; then
    echo "ERROR: pip3 is not installed"
    exit 1
fi

echo "Checking dependencies..."
echo ""

if ! pip3 show fastapi &> /dev/null; then
    echo "Installing dependencies from requirements.txt..."
    pip3 install -r requirements.txt
    echo ""
fi

echo "Verifying PyVHR installation..."
python3 -c "import pyVHR; print('✓ PyVHR is installed and available')" 2>/dev/null || {
    echo "⚠ WARNING: PyVHR is not installed properly"
    echo "Attempting to install PyVHR..."
    pip3 install pyVHR==2.0.0
}

echo ""
echo "=========================================="
echo "Starting FastAPI server on port 8000"
echo "=========================================="
echo ""
echo "Backend will be available at: http://localhost:8000"
echo "Health check endpoint: http://localhost:8000/health"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""

python3 -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload
