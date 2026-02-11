"""
Demo script showing OpenAI integration for real semantic embeddings

To run with OpenAI:
    export OPENAI_API_KEY='your-key'
    python demo_with_openai.py

This demonstrates the difference between:
- Synthetic embeddings (random vectors)
- OpenAI embeddings (semantic understanding)
"""

import os
from local_test_matcher import *

def demo_semantic_matching():
    """
    Show how OpenAI embeddings capture semantic similarity better
    """
    print("\n" + "="*70)
    print("SEMANTIC MATCHING DEMO - OpenAI Embeddings")
    print("="*70)
    
    if not USE_OPENAI:
        print("\n⚠️  OpenAI API key not set!")
        print("   Set OPENAI_API_KEY environment variable to enable")
        print("   For now, using synthetic embeddings...\n")
    else:
        print("\n✓ OpenAI integration enabled")
        print("  Using text-embedding-3-small (1536 dimensions)\n")
    
    # Create a specific seeker scenario
    print("[1] Creating realistic seeker profile...")
    print("-" * 70)
    
    seeker_themes = [
        {"name": "Exam Stress / Academic Pressure", "intensity": 0.95},
        {"name": "Loneliness / Isolation", "intensity": 0.8}
    ]
    
    seeker_vent = """
    I'm completely overwhelmed with finals coming up. I study for hours but 
    nothing sticks. Everyone else seems to have it together but I'm falling 
    apart. I can't sleep, my anxiety is through the roof, and I feel so alone 
    in this. My parents have such high expectations and I'm terrified of 
    disappointing them. I just want someone who understands what it's like.
    """
    
    seeker = {
        "user_id": "Sarah",
        "role": "seeker",
        "themes": seeker_themes,
        "emotion_embedding": generate_emotion_embedding(seeker_vent, use_openai=USE_OPENAI),
        "vent_text": seeker_vent.strip(),
        "coping_style_preference": {
            "problem_focused": 0.3,
            "emotion_focused": 0.8,  # Needs emotional processing first
            "social_support": 0.9,   # Craves connection
            "avoidant": 0.1,
            "meaning_making": 0.4
        },
        "conversation_preference": {
            "direct_advice": 0.3,
            "reflective_listening": 0.9,  # Just needs to be heard
            "collaborative_problem_solving": 0.5,
            "validation_focused": 0.8
        },
        "availability_windows": generate_availability_windows(),
        "energy_level": "depleted",
        "distress_level": "High",
        "urgency": 0.85
    }
    
    print(f"\n🆘 SEEKER: {seeker['user_id']}")
    print(f"   Vent: {seeker_vent[:100]}...")
    print(f"   Themes: {[t['name'] for t in seeker['themes']]}")
    print(f"   State: {seeker['distress_level']} distress, {seeker['energy_level']} energy")
    print(f"   Needs: Validation + emotional processing")
    
    # Create diverse helper profiles
    print("\n[2] Creating helper profiles...")
    print("-" * 70)
    
    helpers = []
    
    # Helper 1: Perfect match
    helper1_exp = "I struggled with exam anxiety throughout college. The pressure from family was intense. I learned that it's okay to not be perfect."
    helpers.append({
        "user_id": "Alex",
        "role": "helper",
        "themes_experience": {
            "Exam Stress / Academic Pressure": 0.95,
            "Loneliness / Isolation": 0.7,
            "Self-Confidence / Self-Esteem": 0.6,
            "Family Problems": 0.4,
            "Friendship / Social Issues": 0.3,
            "Burnout / Emotional Exhaustion": 0.5,
            "Life Direction / Purpose": 0.3
        },
        "emotion_embedding": generate_emotion_embedding(helper1_exp, use_openai=USE_OPENAI),
        "experience_narrative": helper1_exp,
        "coping_style_expertise": {
            "problem_focused": 0.6,
            "emotion_focused": 0.9,
            "social_support": 0.8,
            "avoidant": 0.2,
            "meaning_making": 0.7
        },
        "conversation_style": {
            "direct_advice": 0.3,
            "reflective_listening": 0.95,
            "collaborative_problem_solving": 0.6,
            "validation_focused": 0.9
        },
        "availability_windows": generate_availability_windows(),
        "energy_level": "moderate",
        "energy_consistency": 0.85,
        "reliability_score": 0.92,
        "response_rate": 0.95,
        "completion_rate": 0.88,
        "support_strengths": {
            "empathy": 0.95,
            "lived_experience": 0.9,
            "active_listening": 0.92,
            "boundary_setting": 0.8
        }
    })
    
    # Helper 2: Different issue (burnout, not exams)
    helper2_exp = "I dealt with severe burnout at work. Took time off to recover and find balance."
    helpers.append({
        "user_id": "Jordan",
        "role": "helper",
        "themes_experience": {
            "Burnout / Emotional Exhaustion": 0.95,
            "Life Direction / Purpose": 0.7,
            "Exam Stress / Academic Pressure": 0.2,
            "Loneliness / Isolation": 0.3,
            "Self-Confidence / Self-Esteem": 0.5,
            "Family Problems": 0.3,
            "Friendship / Social Issues": 0.4
        },
        "emotion_embedding": generate_emotion_embedding(helper2_exp, use_openai=USE_OPENAI),
        "experience_narrative": helper2_exp,
        "coping_style_expertise": {
            "problem_focused": 0.8,
            "emotion_focused": 0.5,
            "social_support": 0.4,
            "avoidant": 0.3,
            "meaning_making": 0.8
        },
        "conversation_style": {
            "direct_advice": 0.8,
            "reflective_listening": 0.4,
            "collaborative_problem_solving": 0.7,
            "validation_focused": 0.5
        },
        "availability_windows": generate_availability_windows(),
        "energy_level": "high",
        "energy_consistency": 0.9,
        "reliability_score": 0.88,
        "response_rate": 0.85,
        "completion_rate": 0.92,
        "support_strengths": {
            "empathy": 0.7,
            "lived_experience": 0.8,
            "active_listening": 0.6,
            "boundary_setting": 0.9
        }
    })
    
    # Add some random helpers
    helpers.extend([generate_helper() for _ in range(10)])
    
    print(f"   Created {len(helpers)} helpers")
    print(f"   - Alex: Exam stress + validation-focused")
    print(f"   - Jordan: Burnout + advice-focused")
    print(f"   - 10 random helpers")
    
    # Match and compare
    print("\n[3] Matching seeker with helpers...")
    print("-" * 70)
    
    matches = match_seeker_to_helpers(seeker, helpers, top_k=5, use_learned=False)
    
    print(f"\n🤝 TOP 5 MATCHES:")
    for rank, (score, helper_id, breakdown, helper) in enumerate(matches, 1):
        print(f"\n   {rank}. {helper_id} - Score: {score}")
        print(f"      Emotional Similarity: {breakdown['emotional_similarity']}")
        print(f"      Experience Overlap:   {breakdown['experience_overlap']}")
        print(f"      Coping Match:         {breakdown['coping_style_match']}")
        
        if helper_id in ["Alex", "Jordan"]:
            print(f"      → {helper['experience_narrative']}")
    
    print("\n" + "="*70)
    print("💡 KEY INSIGHTS:")
    print("="*70)
    
    if USE_OPENAI:
        print("\n✓ With OpenAI embeddings:")
        print("  - Semantic similarity captures emotional nuance")
        print("  - 'exam anxiety' close to 'academic pressure'")
        print("  - 'overwhelmed' vs 'burnout' distinguished properly")
        print("  - Helper narratives semantically matched to vent")
    else:
        print("\n⚠️  With synthetic embeddings:")
        print("  - Random vectors, no semantic understanding")
        print("  - Matching relies only on explicit features")
        print("  - Set OPENAI_API_KEY to see the difference!")
    
    print("\n📈 To improve further:")
    print("  1. Collect real conversation feedback")
    print("  2. Train LightGBM on outcomes")
    print("  3. Model learns community-specific patterns")
    print("  4. Personalize weights per user over time")
    print()


if __name__ == "__main__":
    demo_semantic_matching()
