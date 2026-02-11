# 🔑 OpenRouter Setup Guide

Use OpenRouter to access OpenAI's embedding models with your own API key.

## 🚀 Quick Start

### 1. Get Your OpenRouter API Key

Go to: **https://openrouter.ai/keys**
- Sign up (free account)
- Click "Create Key"
- Copy your key (starts with `sk-or-...`)

### 2. Add Credits (Optional)

OpenRouter uses pay-as-you-go pricing:
- Go to: https://openrouter.ai/settings/credits
- Add $5 minimum (goes a long way!)
- Or use their free tier for testing

### 3. Set Your API Key

**Option A: Environment Variable (Recommended)**
```bash
export OPENROUTER_API_KEY='sk-or-v1-...'
```

**Option B: Use OPENAI_API_KEY with OpenRouter key**
```bash
export OPENAI_API_KEY='sk-or-v1-...'
```

### 4. Run Your Code

```bash
# Your code automatically detects OpenRouter
python local_test_matcher.py
```

You should see:
```
✓ OpenRouter Integration Enabled (using openai/text-embedding-3-small)
```

## 💰 Pricing Comparison

### Text Embedding 3 Small via OpenRouter

| Usage | Tokens | Cost |
|-------|--------|------|
| Testing (50 profiles) | ~10K | $0.0002 |
| Small app (1,000 profiles) | ~200K | $0.004 |
| Medium app (10,000 profiles) | ~2M | $0.04 |
| Large app (100,000 profiles) | ~20M | $0.40 |

**Model:** `openai/text-embedding-3-small`  
**Cost:** $0.02 per million tokens  
**Dimensions:** 1536

## 🔧 Testing Your Setup

### Quick Test Script

```bash
# Test with OpenRouter
export OPENROUTER_API_KEY='your-key-here'
python demo_with_openai.py
```

Expected output:
- ✓ OpenRouter integration confirmed
- Real semantic embeddings (not random)
- Better matching scores

### Verify It's Working

Look for these signs:
1. No "falling back to synthetic" messages
2. Embedding similarity scores are consistent
3. Similar text gets high similarity (0.8-0.95)
4. Different text gets low similarity (0.1-0.4)

## 🆚 OpenRouter vs Direct OpenAI

| Feature | OpenRouter | Direct OpenAI |
|---------|------------|---------------|
| **API Key** | `sk-or-...` | `sk-proj-...` |
| **Base URL** | openrouter.ai/api/v1 | api.openai.com/v1 |
| **Model Name** | `openai/text-embedding-3-small` | `text-embedding-3-small` |
| **Pricing** | Same ($0.02/M) | Same ($0.02/M) |
| **Speed** | Slightly slower (proxy) | Faster (direct) |
| **Access** | Multiple providers | OpenAI only |
| **Setup** | Easier (one account) | Requires OpenAI account |

## 🐛 Troubleshooting

### "API initialization failed"
- Check your API key is correct
- Make sure it starts with `sk-or-`
- Verify you have credits in your account

### "401 Unauthorized"
- API key is invalid or expired
- Regenerate key at https://openrouter.ai/keys

### "429 Rate Limited"
- You're sending requests too fast
- OpenRouter has rate limits
- Add delays between requests

### "Insufficient credits"
- Add credits at https://openrouter.ai/settings/credits
- Minimum $5 recommended

## 📊 Monitor Your Usage

Track costs in real-time:
- Dashboard: https://openrouter.ai/activity
- See token usage, cost per request
- Set budget limits to avoid overspending

## 🔐 Security Best Practices

1. **Never commit API keys to git**
   ```bash
   # Add to .gitignore
   echo "*.env" >> .gitignore
   echo ".env.local" >> .gitignore
   ```

2. **Use environment variables**
   ```bash
   # Create .env file (not committed)
   OPENROUTER_API_KEY=sk-or-v1-...
   
   # Load in Python (optional)
   from dotenv import load_dotenv
   load_dotenv()
   ```

3. **Rotate keys regularly**
   - Generate new keys monthly
   - Revoke old keys immediately

## 💡 Pro Tips

1. **Test locally with synthetic first**
   ```bash
   # No API key = free testing
   python local_test_matcher.py
   ```

2. **Only use API for final demo**
   - Saves money
   - Show the difference live

3. **Batch your embeddings**
   - Generate all profiles once
   - Cache the embeddings
   - Reuse for multiple matches

4. **Monitor costs**
   - Check dashboard after each test
   - Set budget alerts

## 🎯 Example: End-to-End Test

```bash
# 1. Set your key
export OPENROUTER_API_KEY='sk-or-v1-YOUR_KEY'

# 2. Run basic test
python local_test_matcher.py

# 3. Run realistic demo
python demo_with_openai.py

# 4. Check costs
# Visit: https://openrouter.ai/activity
# Should be < $0.01 for full test
```

## 📚 Additional Resources

- OpenRouter Docs: https://openrouter.ai/docs
- Pricing Page: https://openrouter.ai/models/openai/text-embedding-3-small
- Status Page: https://status.openrouter.ai
- Support: https://discord.gg/openrouter

---

**Ready?** Get your key at https://openrouter.ai/keys and start testing! 🚀
