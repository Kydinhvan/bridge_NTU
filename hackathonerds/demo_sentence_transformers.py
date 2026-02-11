"""
✅ WORKING Sentence Transformer Demo with Full Matching Algorithm

This version loads Sentence Transformers BEFORE LightGBM to avoid segfault.
Issue: LightGBM and PyTorch/SentenceTransformers have OpenMP conflicts.
"""

import os
import random
import numpy as np
from faker import Faker

# ⚠️ CRITICAL: Load Sentence Transformers BEFORE LightGBM
print("🔬 Sentence Transformer Full Matching Demo")
print("=" * 70)
print("\n[1] Loading Sentence Transformers (BEFORE other ML libraries)...")

try:
    from sentence_transformers import SentenceTransformer
    sentence_model = SentenceTransformer('all-MiniLM-L6-v2', device='cpu')
    print("✅ Sentence Transformers loaded successfully")
    EMBEDDING_MODE = "sentence_transformers"
except Exception as e:
    print(f"❌ Failed to load: {e}")
    sentence_model = None
    EMBEDDING_MODE = "synthetic"

# Now safe to import LightGBM
print("\n[2] Loading other ML libraries...")
import pandas as pd
import lightgbm as lgb
from sklearn.model_selection import train_test_split
print("✅ Pandas, LightGBM, scikit-learn loaded")

fake = Faker()

# ---------------------------
# EMBEDDING FUNCTION
# ---------------------------

def generate_emotion_embedding(text, context="emotion"):
    """Generate embedding using Sentence Transformers"""
    if EMBEDDING_MODE == "sentence_transformers" and sentence_model is not None:
        try:
            embedding = sentence_model.encode(text, convert_to_numpy=True)
            return embedding
        except Exception as e:
            print(f"⚠️  Encoding failed: {e}")
            return np.random.randn(8)
    else:
        # Fallback to synthetic
        return np.random.randn(8)

# ---------------------------
# MATCHING ALGORITHM
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

COPING_STYLES = [
    "validation",  # "just listen to me"
    "advice",      # "tell me what to do"
    "distraction", # "help me forget"
    "processing"   # "help me understand"
]

def compute_emotional_similarity(seeker_embedding, helper_embedding):
    """Cosine similarity between emotion embeddings"""
    if len(seeker_embedding) == 0 or len(helper_embedding) == 0:
        return 0.5
    
    dot = np.dot(seeker_embedding, helper_embedding)
    norm_seeker = np.linalg.norm(seeker_embedding)
    norm_helper = np.linalg.norm(helper_embedding)
    
    if norm_seeker == 0 or norm_helper == 0:
        return 0.5
    
    similarity = dot / (norm_seeker * norm_helper)
    return max(0.0, min(1.0, (similarity + 1) / 2))  # Normalize to [0,1]

def compute_experience_overlap(seeker_themes, helper_themes):
    """Jaccard similarity for themes"""
    if not seeker_themes or not helper_themes:
        return 0.0
    
    seeker_set = set(t["name"] for t in seeker_themes)
    helper_set = set(t["name"] for t in helper_themes)
    
    intersection = len(seeker_set & helper_set)
    union = len(seeker_set | helper_set)
    
    return intersection / union if union > 0 else 0.0

def compute_coping_match(seeker_coping, helper_coping):
    """Binary match for coping styles"""
    return 1.0 if seeker_coping == helper_coping else 0.3

def compute_dha_match_score(seeker, helper):
    """
    Compute match score using weighted formula
    """
    # Emotion embeddings
    emotional_sim = compute_emotional_similarity(
        seeker["emotion_embedding"],
        helper["emotion_embedding"]
    )
    
    # Theme overlap
    experience_overlap = compute_experience_overlap(
        seeker["themes"],
        helper["themes"]
    )
    
    # Coping match
    coping_match = compute_coping_match(
        seeker["coping_style"],
        helper["coping_style"]
    )
    
    # Availability & reliability
    availability = helper.get("availability", 0.5)
    reliability = helper.get("reliability_score", 0.5)
    
    # Weighted score (v3 formula)
    score = (
        0.35 * emotional_sim +
        0.25 * experience_overlap +
        0.15 * coping_match +
        0.15 * availability +
        0.10 * reliability
    )
    
    return {
        "total_score": score,
        "emotional_similarity": emotional_sim,
        "experience_overlap": experience_overlap,
        "coping_match": coping_match,
        "availability": availability,
        "reliability": reliability
    }

def match_seeker_to_helpers(seeker, helpers, top_k=5):
    """Match seeker to top K helpers"""
    matches = []
    
    for helper in helpers:
        score_details = compute_dha_match_score(seeker, helper)
        matches.append({
            "helper": helper,
            "score": score_details["total_score"],
            "details": score_details
        })
    
    # Sort by score descending
    matches.sort(key=lambda x: x["score"], reverse=True)
    
    return matches[:top_k]

# ---------------------------
# DEMO
# ---------------------------

def create_realistic_profiles():
    """Create realistic seeker and helper profiles"""
    
    print("\n[3] Creating realistic profiles...")
    print("-" * 70)
    
    # Seeker: Student stressed about exams
    seeker_vent = """
    I'm completely overwhelmed with finals coming up. I study for hours but 
    nothing sticks. Everyone else seems to have it together but I'm falling 
    apart. My anxiety is through the roof and I feel so alone.
    """
    
    seeker = {
        "user_id": "Sarah",
        "vent": seeker_vent.strip(),
        "themes": [
            {"name": "Exam Stress / Academic Pressure", "intensity": 0.95},
            {"name": "Loneliness / Isolation", "intensity": 0.8}
        ],
        "emotion_embedding": generate_emotion_embedding(seeker_vent, "emotion"),
        "coping_style": "validation",
        "current_state": "high_distress"
    }
    
    print(f"🆘 Seeker: {seeker['user_id']}")
    print(f"   Vent: {seeker['vent'][:80]}...")
    print(f"   Themes: {[t['name'] for t in seeker['themes']]}")
    print(f"   Embedding shape: {seeker['emotion_embedding'].shape}")
    
    # Helper 1: Perfect match (exam stress + validation)
    helper1_bio = """
    I struggled with exam anxiety throughout college. The pressure from family 
    was intense. I learned that it's okay to not be perfect.
    """
    
    helper1 = {
        "user_id": "Alex",
        "bio": helper1_bio.strip(),
        "themes": [
            {"name": "Exam Stress / Academic Pressure", "weight": 0.9}
        ],
        "emotion_embedding": generate_emotion_embedding(helper1_bio, "experience"),
        "coping_style": "validation",
        "availability": 0.9,
        "reliability_score": 0.85
    }
    
    # Helper 2: Mismatched (depression + advice)
    helper2_bio = """
    I overcame depression by finding purpose through volunteer work. 
    Sometimes you need to take action to feel better.
    """
    
    helper2 = {
        "user_id": "Jordan",
        "bio": helper2_bio.strip(),
        "themes": [
            {"name": "Burnout / Emotional Exhaustion", "weight": 0.8}
        ],
        "emotion_embedding": generate_emotion_embedding(helper2_bio, "experience"),
        "coping_style": "advice",
        "availability": 0.7,
        "reliability_score": 0.9
    }
    
    # Helper 3: Random
    helper3_bio = "I dealt with relationship issues and learned to set boundaries."
    helper3 = {
        "user_id": "Sam",
        "bio": helper3_bio,
        "themes": [{"name": "Friendship / Social Issues", "weight": 0.7}],
        "emotion_embedding": generate_emotion_embedding(helper3_bio, "experience"),
        "coping_style": "processing",
        "availability": 0.6,
        "reliability_score": 0.75
    }
    
    helpers = [helper1, helper2, helper3]
    
    print(f"\n🤝 Created {len(helpers)} helpers:")
    for h in helpers:
        print(f"   - {h['user_id']}: {h['themes'][0]['name']}")
    
    return seeker, helpers

def main():
    """Run the demo"""
    
    seeker, helpers = create_realistic_profiles()
    
    print("\n[4] Matching seeker with helpers...")
    print("-" * 70)
    
    matches = match_seeker_to_helpers(seeker, helpers, top_k=3)
    
    print("\n🏆 TOP MATCHES:\n")
    for i, match in enumerate(matches, 1):
        helper = match["helper"]
        score = match["score"]
        details = match["details"]
        
        print(f"   {i}. {helper['user_id']} - Score: {score:.3f}")
        print(f"      Emotional Similarity: {details['emotional_similarity']:.3f}")
        print(f"      Experience Overlap:   {details['experience_overlap']:.3f}")
        print(f"      Coping Match:         {details['coping_match']:.3f}")
        print(f"      Bio: {helper['bio'][:80]}...")
        print()
    
    # Summary
    print("=" * 70)
    print("✅ DEMO COMPLETE!")
    print("=" * 70)
    
    if EMBEDDING_MODE == "sentence_transformers":
        print("\n🎉 Using Sentence Transformers (FREE local embeddings!)")
        print("   - No API costs")
        print("   - Real semantic understanding")
        print("   - 384-dimensional embeddings")
        print("   - Privacy-preserving (100% local)")
    else:
        print("\n⚠️  Using synthetic embeddings (fallback)")
        print("   - Set up Sentence Transformers for real embeddings")
    
    print("\n💡 The best match should be Alex (exam stress + validation style)")
    print("   This shows the algorithm understands semantic similarity!\n")

if __name__ == "__main__":
    main()
