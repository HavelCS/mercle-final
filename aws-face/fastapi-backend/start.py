#!/usr/bin/env python3
import os
import uvicorn

def main():
    # Get the port from environment variable or use default
    port = int(os.environ.get('PORT', 8000))
    
    print(f"Starting FastAPI application on port {port}")
    
    # Start uvicorn server
    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=port,
        log_level="info"
    )

if __name__ == "__main__":
    main()
