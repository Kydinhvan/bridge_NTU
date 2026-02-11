import random
import numpy as np
import pickle
import os
from datetime import datetime

# CRITICAL: Load Sentence Transformers BEFORE LightGBM to avoid OpenMP segfault.
# LightGBM and PyTorch/SentenceTransformers have conflicting OpenMP libraries.
# sentence_transformers must init its OpenMP first.
try:
    from sentence_transformers import SentenceTransformer
    SENTENCE_TRANSFORMERS_AVAILABLE = True
except ImportError:
    SENTENCE_TRANSFORMERS_AVAILABLE = False

import pandas as pd
from faker import Faker
from openai import OpenAI
import lightgbm as lgb
from sklearn.model_selection import train_test_split

fake = Faker()

# Initialize OpenAI/OpenRouter client
# NOTE: We force USE_OPENAI=False for embeddings to use free local sentence_transformers.
# The OpenAI API key is used only for GPT-4o chat completions in api.py.
USE_OPENAI = False
EMBEDDING_MODE = None
openai_client = None
using_openrouter = False

# Initialize Sentence Transformer model as fallback (FREE!)
sentence_model = None
use_sentence_transformers = (
    not USE_OPENAI and 
    SENTENCE_TRANSFORMERS_AVAILABLE and 
    os.getenv("SKIP_SENTENCE_TRANSFORMERS") != "1"
)

if use_sentence_transformers:
    try:
        print("📥 Loading local Sentence Transformer model (free, no API key needed)...")
        print("   This may take a moment on first run (downloads ~90MB model)...")
        print("   Note: If this hangs, set SKIP_SENTENCE_TRANSFORMERS=1")
        # all-MiniLM-L6-v2: 384 dimensions, fast, good quality
        sentence_model = SentenceTransformer('all-MiniLM-L6-v2', device='cpu')  # Force CPU to avoid issues
        EMBEDDING_MODE = "sentence_transformers"
        print("✓ Sentence Transformers Loaded (100% FREE - runs locally)")
        print("  Model: all-MiniLM-L6-v2 (384 dimensions)")
    except Exception as e:
        print(f"⚠️  Could not load Sentence Transformers: {e}")
        print("   Falling back to synthetic embeddings")
        EMBEDDING_MODE = "synthetic"
elif not USE_OPENAI and not SENTENCE_TRANSFORMERS_AVAILABLE:
    print("💡 Tip: Install sentence-transformers for FREE local embeddings:")
    print("   pip install sentence-transformers")
    EMBEDDING_MODE = "synthetic"
elif not USE_OPENAI and os.getenv("SKIP_SENTENCE_TRANSFORMERS") == "1":
    print("⏭️  Skipping Sentence Transformers (SKIP_SENTENCE_TRANSFORMERS=1)")
    EMBEDDING_MODE = "synthetic"

if EMBEDDING_MODE is None:
    EMBEDDING_MODE = "synthetic"
    print("✗ Using synthetic embeddings (set OPENAI_API_KEY, OPENROUTER_API_KEY, or install sentence-transformers)")

# ---------------------------
# CONFIG
# ---------------------------

THEMES = [
    "Exam Stress / Academic Pressure",
    "Family Problems",
    "Friendship / Social Issues",
    "Burnout / Emotional Exhaustion",
    "Loneliness / Isolation",
    "Life Direction / Purpose",
    "Self-Confidence / Self-Esteem"
]

# Emotion embedding dimensions (simulated psychological states)
EMOTION_DIMENSIONS = [
    "anxiety", "sadness", "anger", "confusion", 
    "hopelessness", "overwhelm", "fear", "frustration"
]

# Coping styles based on psychological research
COPING_STYLES = [
    "problem_focused",      # Direct action/solutions
    "emotion_focused",      # Process feelings first
    "avoidant",            # Distraction-based
    "social_support",      # Connection-driven
    "meaning_making"       # Reframing/perspective
]

CONVERSATION_PREFERENCES = [
    "direct_advice",
    "reflective_listening",
    "collaborative_problem_solving",
    "validation_focused"
]

# Updated weights for psychologically smart matching
WEIGHTS = {
    "emotional_similarity": 0.35,
    "experience_overlap": 0.25,
    "coping_style_match": 0.15,
    "availability_overlap": 0.15,
    "helper_reliability_score": 0.10
}

DISTRESS_MAP = {"Low": 0.3, "Medium": 0.6, "High": 1.0}
ENERGY_LEVELS = ["depleted", "low", "moderate", "high"]

# ---------------------------
# SYNTHETIC DATA GENERATORS
# ---------------------------

def generate_emotion_embedding(text=None, use_openai=False):
    """
    Generate emotion embedding vector with multiple backends
    
    Priority order:
    1. OpenAI/OpenRouter API (if API key provided)
    2. Sentence Transformers (free local model)
    3. Synthetic (random fallback)
    
    Args:
        text: Optional text to embed
        use_openai: Whether to try API first
    
    Returns:
        Normalized embedding vector
    """
    if text:
        # Try API first (OpenAI or OpenRouter)
        if use_openai and USE_OPENAI:
            try:
                model = "openai/text-embedding-3-small" if using_openrouter else "text-embedding-3-small"
                
                response = openai_client.embeddings.create(
                    model=model,
                    input=text
                )
                embedding = np.array(response.data[0].embedding)
                return embedding / np.linalg.norm(embedding)  # Normalize
            except Exception as e:
                print(f"API error: {e}, falling back...")
        
        # Try Sentence Transformers (FREE local model)
        if sentence_model is not None:
            try:
                embedding = sentence_model.encode(text, convert_to_numpy=True)
                return embedding / np.linalg.norm(embedding)  # Normalize
            except Exception as e:
                print(f"Sentence Transformer error: {e}, falling back...")
    
    # Fallback: synthetic embedding for testing
    vec = np.random.rand(len(EMOTION_DIMENSIONS))
    return vec / np.linalg.norm(vec)


def generate_helper_narrative(themes_experience):
    """Generate realistic helper experience narrative for embedding"""
    narratives = []
    for theme, score in themes_experience.items():
        if score > 0.6:
            narratives.append(f"I've dealt with {theme.lower()} and learned to cope")
    return ". ".join(narratives) if narratives else "I want to help others through difficult times"


def generate_seeker_vent(themes):
    """Generate realistic seeker vent text for embedding"""
    vents = []
    for theme in themes:
        theme_name = theme["name"]
        if "Exam" in theme_name:
            vents.append("I'm so stressed about my exams, can't sleep, feel like I'm failing")
        elif "Family" in theme_name:
            vents.append("My family doesn't understand me, constant arguments at home")
        elif "Loneliness" in theme_name:
            vents.append("I feel so alone, like no one really gets what I'm going through")
        elif "Burnout" in theme_name:
            vents.append("I'm exhausted all the time, can't keep up, everything feels too much")
        elif "Friendship" in theme_name:
            vents.append("My friends don't seem to care, feeling left out and isolated")
        elif "Direction" in theme_name:
            vents.append("I don't know what I'm doing with my life, feel lost and directionless")
        elif "Confidence" in theme_name:
            vents.append("I feel like such a failure, everyone else has it together but me")
    
    return ". ".join(vents) if vents else "I'm struggling and need someone to talk to"


def generate_availability_windows():
    """Generate weekly availability (hour blocks)"""
    # Simulate 24-hour blocks across 7 days
    return {
        day: [random.choice([0, 1]) for _ in range(24)]
        for day in ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    }


def generate_helper():
    """Generate Helper/Listener profile"""
    themes_experience = {t: random.uniform(0.3, 1.0) for t in THEMES}
    helper_narrative = generate_helper_narrative(themes_experience)
    
    return {
        "user_id": fake.first_name(),
        "role": "helper",
        "themes_experience": themes_experience,
        
        # Emotion embedding - their emotional capacity/understanding
        "emotion_embedding": generate_emotion_embedding(helper_narrative, use_openai=USE_OPENAI),
        "experience_narrative": helper_narrative,
        
        # Coping style expertise (what styles they understand/support best)
        "coping_style_expertise": {
            style: random.uniform(0.5, 1.0) for style in COPING_STYLES
        },
        
        # Conversation preferences
        "conversation_style": {
            pref: random.random() for pref in CONVERSATION_PREFERENCES
        },
        
        # Availability windows
        "availability_windows": generate_availability_windows(),
        
        # Energy level patterns
        "energy_level": random.choice(ENERGY_LEVELS),
        "energy_consistency": random.uniform(0.6, 1.0),  # How reliable their energy is
        
        # Reliability metrics
        "reliability_score": random.uniform(0.7, 1.0),
        "response_rate": random.uniform(0.75, 1.0),
        "completion_rate": random.uniform(0.80, 1.0),
        
        # Support strengths
        "support_strengths": {
            "empathy": random.uniform(0.6, 1.0),
            "lived_experience": random.uniform(0.5, 1.0),
            "active_listening": random.uniform(0.6, 1.0),
            "boundary_setting": random.uniform(0.5, 1.0)
        }
    }


def generate_seeker():
    """Generate Seeker profile (extracted from AI chat/vent)"""
    themes = [
        {"name": random.choice(THEMES), "intensity": round(random.uniform(0.6, 1.0), 2)}
        for _ in range(random.randint(1, 3))
    ]
    seeker_vent = generate_seeker_vent(themes)
    
    return {
        "user_id": fake.first_name(),
        "role": "seeker",
        "themes": themes,
        
        # Emotion embedding - current emotional state
        "emotion_embedding": generate_emotion_embedding(seeker_vent, use_openai=USE_OPENAI),
        "vent_text": seeker_vent,
        
        # Preferred coping style (extracted from vent/chat)
        "coping_style_preference": {
            style: random.random() for style in COPING_STYLES
        },
        
        # What they're seeking
        "conversation_preference": {
            pref: random.random() for pref in CONVERSATION_PREFERENCES
        },
        
        # Availability
        "availability_windows": generate_availability_windows(),
        
        # Current state
        "energy_level": random.choice(ENERGY_LEVELS),
        "distress_level": random.choice(["Low", "Medium", "High"]),
        "urgency": random.uniform(0.3, 1.0)  # How soon they need support
    }


# ---------------------------
# PHASE 2: LEARNING FROM FEEDBACK
# ---------------------------

class FeedbackStore:
    """Stores conversation outcomes for learning"""
    
    def __init__(self, filepath="feedback_data.pkl"):
        self.filepath = filepath
        self.data = []
        self.load()
    
    def add_feedback(self, seeker, helper, match_features, outcome):
        """
        Record a conversation outcome
        
        Args:
            seeker: Seeker profile dict
            helper: Helper profile dict
            match_features: Dict of matching scores
            outcome: Dict with rating, duration, follow_up, etc.
        """
        feedback_entry = {
            "timestamp": datetime.now(),
            "seeker_id": seeker["user_id"],
            "helper_id": helper["user_id"],
            "features": match_features,
            "outcome": outcome
        }
        self.data.append(feedback_entry)
        self.save()
    
    def save(self):
        """Save feedback to disk"""
        with open(self.filepath, 'wb') as f:
            pickle.dump(self.data, f)
    
    def load(self):
        """Load feedback from disk"""
        if os.path.exists(self.filepath):
            with open(self.filepath, 'rb') as f:
                self.data = pickle.load(f)
    
    def get_training_data(self):
        """Convert feedback to training dataset"""
        if not self.data:
            return None, None
        
        X = []  # Features
        y = []  # Labels (conversation quality)
        
        for entry in self.data:
            features = entry["features"]
            outcome = entry["outcome"]
            
            # Feature vector
            feature_vec = [
                features["emotional_similarity"],
                features["experience_overlap"],
                features["coping_style_match"],
                features["availability_overlap"],
                features["reliability_score"],
                features["conversation_bonus"],
                features["energy_bonus"]
            ]
            
            # Label: composite quality score
            quality = (
                0.5 * outcome["user_rating"] +  # 0-5 scale
                0.3 * outcome["conversation_length"] +  # Normalized 0-1
                0.2 * outcome["follow_up_likelihood"]  # 0-1
            )
            
            X.append(feature_vec)
            y.append(quality)
        
        return np.array(X), np.array(y)


class LearnedMatcher:
    """
    Matcher that learns optimal weights from feedback
    Uses LightGBM to predict match quality
    """
    
    def __init__(self, model_path="matcher_model.txt"):
        self.model_path = model_path
        self.model = None
        self.is_trained = False
        self.load()
    
    def train(self, X, y, verbose=True):
        """
        Train the model on feedback data
        
        Args:
            X: Feature matrix (n_samples, n_features)
            y: Target labels (conversation quality scores)
        """
        if len(X) < 10:
            if verbose:
                print(f"⚠️  Need at least 10 samples to train, got {len(X)}")
            return False
        
        # Split train/test
        X_train, X_test, y_train, y_test = train_test_split(
            X, y, test_size=0.2, random_state=42
        )
        
        # Create LightGBM dataset
        train_data = lgb.Dataset(X_train, label=y_train)
        test_data = lgb.Dataset(X_test, label=y_test, reference=train_data)
        
        # Training parameters
        params = {
            'objective': 'regression',
            'metric': 'rmse',
            'boosting_type': 'gbdt',
            'num_leaves': 31,
            'learning_rate': 0.05,
            'feature_fraction': 0.9,
            'verbose': -1
        }
        
        # Train
        self.model = lgb.train(
            params,
            train_data,
            num_boost_round=100,
            valid_sets=[test_data],
            callbacks=[lgb.early_stopping(stopping_rounds=10, verbose=False)]
        )
        
        self.is_trained = True
        self.save()
        
        if verbose:
            # Evaluate
            y_pred = self.model.predict(X_test)
            rmse = np.sqrt(np.mean((y_pred - y_test) ** 2))
            print(f"✓ Model trained on {len(X)} samples, RMSE: {rmse:.3f}")
            
            # Feature importance
            importance = self.model.feature_importance()
            feature_names = [
                "emotional_sim", "experience_overlap", "coping_match",
                "availability", "reliability", "conversation_bonus", "energy_bonus"
            ]
            print(f"  Feature importance: {dict(zip(feature_names, importance))}")
        
        return True
    
    def predict(self, features):
        """
        Predict match quality score
        
        Args:
            features: Dict with all matching features
        
        Returns:
            Predicted quality score (0-1)
        """
        if not self.is_trained or self.model is None:
            # Fallback to rule-based
            return None
        
        feature_vec = np.array([[
            features["emotional_similarity"],
            features["experience_overlap"],
            features["coping_style_match"],
            features["availability_overlap"],
            features["reliability_score"],
            features["conversation_bonus"],
            features["energy_bonus"]
        ]])
        
        return self.model.predict(feature_vec)[0]
    
    def save(self):
        """Save model to disk"""
        if self.model:
            self.model.save_model(self.model_path)
    
    def load(self):
        """Load model from disk"""
        if os.path.exists(self.model_path):
            try:
                self.model = lgb.Booster(model_file=self.model_path)
                self.is_trained = True
            except:
                pass


# Global instances
feedback_store = FeedbackStore()
learned_matcher = LearnedMatcher()

# ---------------------------
# PSYCHOLOGICALLY SMART SCORING FUNCTIONS
# ---------------------------

def cosine_similarity(vec1, vec2):
    """Calculate cosine similarity between two vectors"""
    dot_product = np.dot(vec1, vec2)
    norm_product = np.linalg.norm(vec1) * np.linalg.norm(vec2)
    return dot_product / norm_product if norm_product > 0 else 0


def emotion_embedding_similarity(seeker, helper):
    """
    0.35 weight: Measures emotional state alignment
    High score = helper understands seeker's emotional landscape
    """
    return cosine_similarity(
        seeker["emotion_embedding"],
        helper["emotion_embedding"]
    )


def experience_overlap_score(seeker, helper):
    """
    0.25 weight: Measures lived experience overlap with themes
    High score = helper has been through similar issues
    """
    overlap = 0.0
    total_intensity = 0.0
    
    for theme in seeker["themes"]:
        theme_name = theme["name"]
        intensity = theme["intensity"]
        helper_exp = helper["themes_experience"].get(theme_name, 0)
        
        overlap += intensity * helper_exp
        total_intensity += intensity
    
    return overlap / total_intensity if total_intensity > 0 else 0


def coping_style_compatibility(seeker, helper):
    """
    0.15 weight: Measures alignment in coping approaches
    High score = helper supports seeker's natural coping style
    """
    compatibility = 0.0
    
    for style in COPING_STYLES:
        seeker_pref = seeker["coping_style_preference"].get(style, 0)
        helper_expertise = helper["coping_style_expertise"].get(style, 0)
        compatibility += seeker_pref * helper_expertise
    
    return compatibility / len(COPING_STYLES)


def conversation_preference_match(seeker, helper):
    """
    Measures alignment in conversation style preferences
    Direct advice vs reflective listening vs collaborative problem-solving
    """
    match_score = 0.0
    
    for pref in CONVERSATION_PREFERENCES:
        seeker_want = seeker["conversation_preference"].get(pref, 0)
        helper_style = helper["conversation_style"].get(pref, 0)
        match_score += seeker_want * helper_style
    
    return match_score / len(CONVERSATION_PREFERENCES)


def availability_overlap_score(seeker, helper):
    """
    0.15 weight: Measures schedule compatibility
    High score = many overlapping time windows
    """
    if "availability_windows" not in seeker or "availability_windows" not in helper:
        return 0.5  # Neutral default when availability data is missing

    total_overlap = 0
    total_slots = 0
    
    for day in ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]:
        seeker_slots = seeker["availability_windows"].get(day, [])
        helper_slots = helper["availability_windows"].get(day, [])
        
        for s_avail, h_avail in zip(seeker_slots, helper_slots):
            if s_avail == 1 and h_avail == 1:
                total_overlap += 1
            total_slots += 1
    
    return total_overlap / total_slots if total_slots > 0 else 0


def energy_level_compatibility(seeker, helper):
    """
    Bonus: Energy matching (integrated into conversation match)
    Depleted seeker shouldn't get high-energy helper (overwhelming)
    """
    energy_map = {"depleted": 0, "low": 1, "moderate": 2, "high": 3}
    s_energy = energy_map.get(seeker.get("energy_level", "moderate"), 2)
    h_energy = energy_map.get(helper.get("energy_level", "moderate"), 2)
    
    # Prefer helpers 1-2 levels above seeker (supportive but not overwhelming)
    diff = h_energy - s_energy
    if 0 <= diff <= 2:
        return 1.0
    elif diff < 0:
        return 0.7  # Helper lower energy - still okay
    else:
        return 0.5  # Helper too high energy - might overwhelm


def helper_reliability_score(helper):
    """
    0.10 weight: Composite reliability metric
    Based on past performance, response rate, completion rate
    """
    return (
        0.5 * helper["reliability_score"] +
        0.3 * helper["response_rate"] +
        0.2 * helper["completion_rate"]
    )


def theme_narrative_match_score(seeker, helper):
    """
    Bonus: If the helper has per-theme AI-scored narratives (theme_scores),
    compute a mirrored similarity against the seeker's profile dimensions.
    
    Seeker dimensions used for mirroring:
      - distress_level → compared to helper's emotional_depth & resilience
      - coping_style_preference → compared to helper's coping_method per theme
      - energy_level → compared to helper's approach_style
      - conversation_preference → compared to helper's communication_tone
    
    Returns 0.0-1.0 bonus score (0 if no theme_scores data).
    """
    theme_scores = helper.get("theme_scores")
    if not theme_scores:
        return 0.0

    seeker_themes = seeker.get("themes_experience", {})
    if not seeker_themes:
        return 0.0

    matching_scores = []
    for theme_name, seeker_intensity in seeker_themes.items():
        if theme_name not in theme_scores or seeker_intensity < 0.1:
            continue
        ts = theme_scores[theme_name]

        # 1. Emotional depth vs seeker distress (deeper helper = better for distressed seeker)
        distress_map = {"Low": 0.3, "Medium": 0.6, "High": 0.9}
        seeker_distress = distress_map.get(seeker.get("distress_level", "Medium"), 0.6)
        depth_match = 1.0 - abs(ts.get("emotional_depth", 0.5) - seeker_distress)

        # 2. Resilience: higher is better (helper should have processed it)
        resilience = ts.get("resilience_demonstrated", 0.5)

        # 3. Empathy signal: higher is better match quality
        empathy = ts.get("empathy_signal", 0.5)

        # 4. Self-awareness: higher is better
        awareness = ts.get("self_awareness", 0.5)

        # 5. Coping method alignment with seeker preference
        coping_method = ts.get("coping_method", "emotion_focused")
        seeker_coping_prefs = seeker.get("coping_style_preference", {})
        coping_alignment = seeker_coping_prefs.get(coping_method, 0.5)

        # 6. Communication tone alignment with seeker preference
        comm_tone = ts.get("communication_tone", "reflective_listening")
        seeker_conv_prefs = seeker.get("conversation_preference", {})
        comm_alignment = seeker_conv_prefs.get(comm_tone, 0.5)

        # Weighted combination per theme
        theme_match = (
            0.20 * depth_match +
            0.15 * resilience +
            0.20 * empathy +
            0.10 * awareness +
            0.20 * coping_alignment +
            0.15 * comm_alignment
        )
        matching_scores.append(theme_match * seeker_intensity)

    if not matching_scores:
        return 0.0

    return sum(matching_scores) / len(matching_scores)


def compute_dha_match_score(seeker, helper, use_learned=True):
    """
    Dha Matching Algorithm - Psychologically Smart + Learning
    
    Args:
        seeker: Seeker profile dict
        helper: Helper profile dict
        use_learned: Whether to use learned model (if available)
    
    Returns:
        (score, breakdown_dict) tuple
    
    Weighted formula (rule-based):
    score = 0.35 * emotional_similarity +
            0.25 * experience_overlap +
            0.15 * coping_style_match +
            0.15 * availability_overlap +
            0.10 * helper_reliability_score
    
    Plus conversation preference & energy bonuses
    
    If learned model available: uses ML prediction instead
    """
    
    # Core weighted components
    emotional_sim = emotion_embedding_similarity(seeker, helper)
    experience_over = experience_overlap_score(seeker, helper)
    coping_match = coping_style_compatibility(seeker, helper)
    availability_over = availability_overlap_score(seeker, helper)
    reliability = helper_reliability_score(helper)
    
    # Bonus adjustments
    conversation_bonus = 0.10 * conversation_preference_match(seeker, helper)
    energy_bonus = 0.05 * energy_level_compatibility(seeker, helper)
    narrative_bonus = 0.10 * theme_narrative_match_score(seeker, helper)
    
    # Feature breakdown
    features = {
        "emotional_similarity": round(emotional_sim, 3),
        "experience_overlap": round(experience_over, 3),
        "coping_style_match": round(coping_match, 3),
        "availability_overlap": round(availability_over, 3),
        "reliability_score": round(reliability, 3),
        "conversation_bonus": round(conversation_bonus, 3),
        "energy_bonus": round(energy_bonus, 3),
        "narrative_match_bonus": round(narrative_bonus, 3),
    }
    
    # Try learned model first
    if use_learned and learned_matcher.is_trained:
        ml_score = learned_matcher.predict(features)
        if ml_score is not None:
            features["score_source"] = "learned_model"
            return round(ml_score, 3), features
    
    # Fallback: rule-based scoring
    core_score = (
        WEIGHTS["emotional_similarity"] * emotional_sim +
        WEIGHTS["experience_overlap"] * experience_over +
        WEIGHTS["coping_style_match"] * coping_match +
        WEIGHTS["availability_overlap"] * availability_over +
        WEIGHTS["helper_reliability_score"] * reliability
    )
    
    final_score = core_score + conversation_bonus + energy_bonus + narrative_bonus
    features["score_source"] = "rule_based"
    
    return round(final_score, 3), features


# ---------------------------
# DHA MATCH ENGINE
# ---------------------------

# ---------------------------
# DHA MATCH ENGINE
# ---------------------------

def simulate_conversation_outcome(match_score, breakdown):
    """
    Simulate a conversation outcome based on match quality
    In real app, this would come from actual user feedback
    
    Args:
        match_score: The predicted match score
        breakdown: Feature breakdown dict
    
    Returns:
        Outcome dict with rating, duration, follow_up likelihood
    """
    # Base quality correlates with match score
    base_quality = match_score
    
    # Add some noise (real world variability)
    noise = np.random.normal(0, 0.1)
    
    # User rating (1-5 scale)
    rating = np.clip(base_quality * 5 + noise, 1, 5)
    
    # Conversation length (normalized 0-1, represents engagement)
    # Good matches = longer conversations
    length = np.clip(base_quality + np.random.normal(0, 0.15), 0, 1)
    
    # Follow-up likelihood (0-1)
    # If conversation went well, they'll reconnect
    follow_up = np.clip(base_quality + np.random.normal(0, 0.2), 0, 1)
    
    return {
        "user_rating": round(rating, 2),
        "conversation_length": round(length, 3),
        "follow_up_likelihood": round(follow_up, 3),
        "timestamp": datetime.now()
    }


def match_seeker_to_helpers(seeker, helpers, top_k=5, min_score=0.5, use_learned=True):
    """
    Main matching function - returns top K helpers for a seeker
    
    Args:
        seeker: Seeker profile dict
        helpers: List of Helper profile dicts
        top_k: Number of top matches to return
        min_score: Minimum score threshold (filters out poor matches)
        use_learned: Whether to use learned model
    
    Returns:
        List of (score, helper_id, breakdown) tuples
    """
    scored = []
    
    for helper in helpers:
        score, breakdown = compute_dha_match_score(seeker, helper, use_learned=use_learned)
        
        # Only include if meets minimum threshold
        if score >= min_score:
            scored.append((score, helper["user_id"], breakdown, helper))
    
    # Sort by score descending
    scored.sort(reverse=True, key=lambda x: x[0])
    
    return scored[:top_k]


def discover_by_theme(theme_name, helpers, top_k=10):
    """
    Netflix-style discovery: Browse helpers by theme
    Returns helpers sorted by experience in that theme
    
    Args:
        theme_name: Name of the theme to browse
        helpers: List of Helper profile dicts
        top_k: Number of results to return
    
    Returns:
        List of (experience_score, helper_id) tuples
    """
    themed = []
    
    for helper in helpers:
        exp_score = helper["themes_experience"].get(theme_name, 0)
        reliability = helper_reliability_score(helper)
        
        # Combined score: 70% experience, 30% reliability
        combined = 0.7 * exp_score + 0.3 * reliability
        themed.append((round(combined, 3), helper["user_id"]))
    
    themed.sort(reverse=True)
    return themed[:top_k]


# ---------------------------
# RUN LOCAL TEST - DHA ALGORITHM v3 + LEARNING
# ---------------------------

if __name__ == "__main__":
    
    print("\n" + "="*70)
    print("DHA MATCHING ALGORITHM v3 - PSYCHOLOGICALLY SMART + LEARNING")
    print("="*70)
    
    # Show embedding mode
    mode_display = {
        "openai": "OpenAI Embeddings (text-embedding-3-small, 1536D)",
        "openrouter": "OpenRouter → OpenAI Embeddings (text-embedding-3-small, 1536D)",
        "sentence_transformers": "🆓 FREE - Sentence Transformers (all-MiniLM-L6-v2, 384D)",
        "synthetic": "Synthetic (Random, for testing only)"
    }
    
    print(f"Embedding Mode: {mode_display.get(EMBEDDING_MODE, 'Unknown')}")
    print(f"Learned Model: {'Active' if learned_matcher.is_trained else 'Not trained yet'}")
    
    # Generate synthetic helper database
    print("\n[1] Generating 50 Helper/Listener profiles...")
    helpers_db = [generate_helper() for _ in range(50)]
    print(f"    ✓ {len(helpers_db)} helpers ready")
    
    # Phase 1: Collect training data by simulating conversations
    print("\n[2] Simulating 30 conversations to collect training data...")
    print("-" * 70)
    
    for i in range(30):
        seeker = generate_seeker()
        # Get top match using rule-based system
        matches = match_seeker_to_helpers(seeker, helpers_db, top_k=1, use_learned=False)
        
        if matches:
            score, helper_id, breakdown, helper = matches[0]
            
            # Simulate conversation outcome
            outcome = simulate_conversation_outcome(score, breakdown)
            
            # Store feedback
            feedback_store.add_feedback(seeker, helper, breakdown, outcome)
            
            if i % 10 == 0:
                print(f"  Conversation {i+1}/30: Rating {outcome['user_rating']:.1f}/5.0")
    
    print(f"  ✓ Collected {len(feedback_store.data)} conversation outcomes")
    
    # Phase 2: Train the model
    print("\n[3] Training LightGBM model on feedback data...")
    print("-" * 70)
    
    X, y = feedback_store.get_training_data()
    if X is not None:
        success = learned_matcher.train(X, y, verbose=True)
        if success:
            print("  ✓ Model training complete!")
    else:
        print("  ⚠️  No training data available")
    
    # Phase 3: Compare rule-based vs learned matching
    print("\n[4] Testing: Rule-Based vs Learned Model...")
    print("-" * 70)
    
    test_seeker = generate_seeker()
    
    print(f"\n🆘 TEST SEEKER: {test_seeker['user_id']}")
    print(f"   Themes: {[t['name'] for t in test_seeker['themes']]}")
    print(f"   Distress: {test_seeker['distress_level']} | Energy: {test_seeker['energy_level']}")
    
    # Rule-based matching
    print(f"\n   📊 RULE-BASED MATCHING (Fixed Weights):")
    rule_matches = match_seeker_to_helpers(test_seeker, helpers_db, top_k=3, use_learned=False)
    for rank, (score, helper_id, breakdown, _) in enumerate(rule_matches, 1):
        print(f"   {rank}. {helper_id} (Score: {score})")
        print(f"      └─ Emotional: {breakdown['emotional_similarity']} | "
              f"Experience: {breakdown['experience_overlap']}")
    
    # Learned matching
    if learned_matcher.is_trained:
        print(f"\n   🧠 LEARNED MATCHING (ML-Optimized):")
        learned_matches = match_seeker_to_helpers(test_seeker, helpers_db, top_k=3, use_learned=True)
        for rank, (score, helper_id, breakdown, _) in enumerate(learned_matches, 1):
            print(f"   {rank}. {helper_id} (Score: {score})")
            print(f"      └─ Emotional: {breakdown['emotional_similarity']} | "
                  f"Experience: {breakdown['experience_overlap']}")
    
    # Phase 4: Continuous improvement demo
    print("\n[5] Continuous Learning Demo...")
    print("-" * 70)
    print("   As more conversations happen, the model improves:")
    print("   • User gives 5-star rating → increases weight of those features")
    print("   • Poor conversation → learns to avoid similar matches")
    print("   • Patterns emerge: 'energy_match matters more for burnout cases'")
    print("   • Algorithm adapts to your community's preferences")
    
    # Show feature importance if trained
    if learned_matcher.is_trained and learned_matcher.model:
        print("\n   📈 Current Feature Importance (learned from data):")
        importance = learned_matcher.model.feature_importance()
        feature_names = [
            "Emotional Sim", "Experience", "Coping Style",
            "Availability", "Reliability", "Conversation", "Energy"
        ]
        importance_pairs = sorted(
            zip(feature_names, importance),
            key=lambda x: x[1],
            reverse=True
        )
        for feat, imp in importance_pairs:
            bar = "█" * int(imp / 10)
            print(f"      {feat:20s} {bar} {int(imp)}")
    
    print("\n" + "="*70)
    print("✅ Dha Algorithm v3 + Learning Test Complete")
    print("="*70)
    print("\n🎯 What Just Happened:")
    print("  1. Generated synthetic helper profiles")
    print("  2. Simulated 30 conversations with feedback")
    print("  3. Trained ML model to learn optimal matching weights")
    print("  4. Compared rule-based vs learned predictions")
    print("  5. Model continuously improves with more data")
    print("\n💡 In Production:")
    print("  • Real user vents → OpenAI embeddings (1536D)")
    print("  • Actual conversation ratings → train model")
    print("  • Algorithm learns what makes good matches in YOUR community")
    print("  • Personalized matching per user over time")
    print()
