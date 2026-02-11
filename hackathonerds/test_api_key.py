"""
Quick test to verify OpenAI API key is working.
Run: python test_api_key.py
"""

import os
from dotenv import load_dotenv

load_dotenv()

api_key = os.getenv("OPENAI_API_KEY")

if not api_key:
    print("[ERROR] OPENAI_API_KEY not found in .env")
    exit(1)

print(f"[INFO] Key found: {api_key[:8]}...{api_key[-4:]}")

try:
    from openai import OpenAI
    client = OpenAI(api_key=api_key)

    print("[INFO] Sending test request to GPT-4o...")
    response = client.chat.completions.create(
        model="gpt-4o",
        messages=[{"role": "user", "content": "Reply with exactly: API key works"}],
        max_tokens=10,
    )

    reply = response.choices[0].message.content.strip()
    print(f"[OK]   GPT-4o response: {reply}")
    print(f"[INFO] Tokens used: {response.usage.total_tokens}")

except Exception as e:
    print(f"[ERROR] {e}")
