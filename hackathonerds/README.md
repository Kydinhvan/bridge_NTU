# Speech-to-Text (STT)

Real-time speech-to-text transcription that types directly into your active window.

## Installation

```bash
pip install -r requirements.txt
```

## Usage

Basic usage with default settings:
```bash
python stt.py
```

With custom model:
```bash
python stt.py -m large-v2
```

With custom language:
```bash
python stt.py -l es
```

## Arguments

- `-m, --model`: Model size (tiny, base, small, medium, large-v2, etc.) Default: small.en
- `-r, --rt-model`: Real-time model size. Default: tiny.en
- `-l, --lang`: Language code (en, es, fr, etc.) Default: en
- `-d, --root`: Root directory for model downloads

## How It Works

1. Start speaking after running the script
2. Text is transcribed in real-time
3. Completed sentences are automatically typed into your active window
4. Press Ctrl+C to stop

## Configuration

Edit `WRITE_TO_KEYBOARD_INTERVAL` in stt.py to adjust typing speed (0 to disable, 0.002 is fast, 0.05 is slower).
# 🧠 Dha Matching Algorithm v3 - Psychologically Smart + Learning

A peer support matching algorithm that connects **Seekers** (people seeking emotional support) with **Helpers** (people with lived experience) using psychological research, AI embeddings, and machine learning.

## 🚀 Features

### Phase 1: OpenAI Embeddings (Implemented)
- **Real semantic understanding** via OpenAI `text-embedding-3-small` (1536D)
- Replaces random emotion vectors with meaningful representations
- Captures nuanced emotional states from text
- Fallback to synthetic embeddings for testing without API key

### Phase 2: Learning from Feedback (Implemented)
- **LightGBM model** learns optimal matching weights from conversation outcomes
- Trains on user ratings, conversation length, and follow-up likelihood
- Improves accuracy over time as more conversations happen
- Persistent storage of feedback data and trained models

### Core Matching Algorithm

**Weighted Formula:**
```
score = 0.35 × emotional_similarity +
        0.25 × experience_overlap +
        0.15 × coping_style_match +
        0.15 × availability_overlap +
        0.10 × helper_reliability_score +
        bonuses (conversation + energy)
```

**Key Components:**
- 🧠 **Emotion Embedding Similarity** - Cosine similarity between emotional states
- 📚 **Experience Overlap** - Helper's lived experience with seeker's themes
- 🎯 **Coping Style Compatibility** - Matching coping approaches (problem-focused, emotion-focused, etc.)
- 📅 **Availability Overlap** - Time window matching across weekly schedules
- ⭐ **Helper Reliability** - Response rate, completion rate, past performance
- 💬 **Conversation Preferences** - Direct advice vs reflective listening
- ⚡ **Energy Level Matching** - Prevents overwhelm in vulnerable states

## 📦 Installation

```bash
pip install numpy faker openai lightgbm pandas scikit-learn

# Optional: For FREE local embeddings (no API key needed)
pip install sentence-transformers
```

## 🔑 Embedding Options (3 Modes)

### Option 1: 🆓 FREE - Sentence Transformers (Recommended for Testing)
- **Cost:** $0 (runs on your computer)
- **Quality:** High (384D semantic embeddings)
- **Speed:** Fast (local processing)
- **Privacy:** Data never leaves your machine

```bash
# No setup needed! Just run:
python local_test_matcher.py

# Or if you have issues with Sentence Transformers:
SKIP_SENTENCE_TRANSFORMERS=1 python local_test_matcher.py
```

### Option 2: OpenAI API (Best Quality)
- **Cost:** $0.02 per million tokens (~$0.004 for 1000 profiles)
- **Quality:** Highest (1536D embeddings)
- **Setup:** Requires OpenAI account

```bash
export OPENAI_API_KEY='sk-proj-...'
python local_test_matcher.py
```

### Option 3: OpenRouter (Easiest Setup)
- **Cost:** Same as OpenAI ($0.02/M)
- **Quality:** Same (uses OpenAI's model)
- **Setup:** Single API key for multiple providers

```bash
export OPENROUTER_API_KEY='sk-or-...'
python local_test_matcher.py
```

See [OPENROUTER_SETUP.md](OPENROUTER_SETUP.md) for detailed OpenRouter instructions.

## 🎯 Usage

### Basic Matching
```python
from local_test_matcher import *

# Generate profiles
seeker = generate_seeker()
helpers = [generate_helper() for _ in range(50)]

# Get matches (uses learned model if available)
matches = match_seeker_to_helpers(seeker, helpers, top_k=5)

for score, helper_id, breakdown, helper in matches:
    print(f"{helper_id}: {score}")
```

### Collect Feedback & Train Model
```python
# After a conversation happens
outcome = {
    "user_rating": 4.5,  # 1-5 scale
    "conversation_length": 0.8,  # Normalized engagement
    "follow_up_likelihood": 0.9  # Will they reconnect?
}

feedback_store.add_feedback(seeker, helper, breakdown, outcome)

# Train model when enough data collected
X, y = feedback_store.get_training_data()
learned_matcher.train(X, y)

# Future matches now use learned weights
```

### Netflix-Style Discovery
```python
# Browse helpers by theme
helpers = discover_by_theme("Exam Stress / Academic Pressure", helpers_db, top_k=10)
```

## 📊 How Learning Works

1. **Initial Phase**: Uses rule-based weights (psychological research)
2. **Data Collection**: Records conversation outcomes (rating, length, follow-up)
3. **Model Training**: LightGBM learns which features predict good matches
4. **Continuous Improvement**: Model updates as more feedback arrives
5. **Personalization**: Can learn different weights for different user groups

**Example Learning:**
- "Users with burnout rate energy_match higher" → increase energy weight for burnout cases
- "Experienced helpers get better ratings" → increase experience_overlap weight
- "Availability matters less than expected" → decrease availability weight

## 🧪 Testing

Run the test suite:
```bash
python local_test_matcher.py
```

**What it does:**
1. Generates 50 helper profiles
2. Simulates 30 conversations with outcomes
3. Trains ML model on feedback
4. Compares rule-based vs learned matching
5. Shows feature importance

## 📈 Production Integration

### Real Application Flow
```python
# 1. User vents via voice/text
user_vent = "I'm so stressed about exams, can't sleep..."

# 2. Generate embedding
import openai
embedding = openai.embeddings.create(
    input=user_vent,
    model="text-embedding-3-small"
)

# 3. Create seeker profile
seeker = {
    "emotion_embedding": embedding.data[0].embedding,
    "themes": extract_themes_with_llm(user_vent),  # GPT-4
    # ... other fields
}

# 4. Match with helpers
matches = match_seeker_to_helpers(seeker, helpers_db)

# 5. After conversation, collect feedback
outcome = get_user_feedback()  # Rating form
feedback_store.add_feedback(seeker, matched_helper, breakdown, outcome)

# 6. Periodically retrain
if len(feedback_store.data) % 50 == 0:
    X, y = feedback_store.get_training_data()
    learned_matcher.train(X, y)
```

## 🔮 Future Enhancements

- [ ] **Per-user personalization** - Different weights per individual
- [ ] **Contextual bandits** - Explore-exploit tradeoff
- [ ] **Graph Neural Networks** - Network effects in matching
- [ ] **Multi-task learning** - Joint prediction of rating, duration, follow-up
- [ ] **Real-time feedback** - Update model incrementally
- [ ] **A/B testing framework** - Compare matching strategies

## 📁 Files

- `local_test_matcher.py` - Main algorithm + learning system
- `feedback_data.pkl` - Stored conversation outcomes (auto-created)
- `matcher_model.txt` - Trained LightGBM model (auto-created)
- `README.md` - This file

## 🏆 Hackathon Demo Tips

1. **Show the learning** - Run with/without training to show improvement
2. **Compare strategies** - Rule-based vs ML predictions side-by-side
3. **Feature importance** - Visualize what the algorithm learned
4. **Real embeddings** - Use OpenAI API for impressive semantic matching
5. **End-to-end flow** - Vent → Profile → Match → Feedback → Learning

## 🤝 Two-Role System

### Seeker
- Vents a problem via text/voice
- AI extracts profile (themes, emotions, preferences)
- Gets matched with top helpers
- Provides feedback after conversation

### Helper/Listener
- Onboards via AI chat about their experiences
- Profile stored as candidate in pool
- Gets matched with seekers they can help
- Builds reliability score over time

## 📚 Technology Stack

- **Python 3.11+**
- **NumPy** - Vector operations
- **OpenAI API** - Semantic embeddings (optional)
- **LightGBM** - Gradient boosting for learning
- **Pandas** - Data handling
- **scikit-learn** - ML utilities
- **Faker** - Synthetic test data

## 📄 License

Open source for hackathon use.

---

Built with ❤️ for mental health peer support. Questions? Check the code comments!
