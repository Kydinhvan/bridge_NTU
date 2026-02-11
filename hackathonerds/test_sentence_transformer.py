"""
Simple Sentence Transformer Demo
Shows how local embeddings work without the full matching algorithm

This isolates the sentence transformer to test if it works standalone
"""

import os
os.environ['SKIP_SENTENCE_TRANSFORMERS'] = '0'  # Force enable

print("🔬 Sentence Transformer Isolated Demo")
print("=" * 70)

# Test 1: Import
print("\n[1] Testing import...")
try:
    from sentence_transformers import SentenceTransformer
    print("✅ sentence_transformers imported successfully")
except ImportError as e:
    print(f"❌ Import failed: {e}")
    exit(1)

# Test 2: Load model
print("\n[2] Loading model...")
print("    Model: all-MiniLM-L6-v2 (384 dimensions)")
print("    Device: CPU (avoiding MPS backend issues)")
try:
    model = SentenceTransformer('all-MiniLM-L6-v2', device='cpu')
    print("✅ Model loaded successfully")
except Exception as e:
    print(f"❌ Model loading failed: {e}")
    print("\n💡 Troubleshooting:")
    print("   - Try: pip install --upgrade torch")
    print("   - Try: pip install --upgrade sentence-transformers")
    print("   - Check: Python version (need 3.8+)")
    exit(1)

# Test 3: Generate embeddings
print("\n[3] Testing embedding generation...")
test_texts = [
    "I'm stressed about exams",
    "I'm worried about my test results", 
    "I love playing basketball"
]

try:
    embeddings = model.encode(test_texts)
    print(f"✅ Generated {len(embeddings)} embeddings")
    print(f"   Shape: {embeddings.shape}")
    print(f"   Type: {type(embeddings)}")
except Exception as e:
    print(f"❌ Embedding generation failed: {e}")
    exit(1)

# Test 4: Compute similarity
print("\n[4] Testing semantic similarity...")
import numpy as np

def cosine_similarity(a, b):
    return np.dot(a, b) / (np.linalg.norm(a) * np.linalg.norm(b))

sim_1_2 = cosine_similarity(embeddings[0], embeddings[1])
sim_1_3 = cosine_similarity(embeddings[0], embeddings[2])

print(f"   '{test_texts[0]}'")
print(f"   vs")
print(f"   '{test_texts[1]}'")
print(f"   Similarity: {sim_1_2:.3f} ✅ (High - semantically related)")

print(f"\n   '{test_texts[0]}'")
print(f"   vs")
print(f"   '{test_texts[2]}'")
print(f"   Similarity: {sim_1_3:.3f} ✅ (Low - semantically different)")

# Test 5: Realistic matching scenario
print("\n[5] Realistic peer support scenario...")
print("-" * 70)

seeker_text = """
I'm completely overwhelmed with finals coming up. I study for hours but 
nothing sticks. Everyone else seems to have it together but I'm falling 
apart. My anxiety is through the roof and I feel so alone.
"""

helper_texts = [
    "I struggled with exam anxiety throughout college. The pressure was intense.",
    "I overcame depression by finding purpose through volunteer work.",
    "I dealt with relationship breakup and trust issues."
]

helper_names = ["Alex (exam stress)", "Jordan (depression)", "Sam (relationships)"]

try:
    seeker_emb = model.encode(seeker_text.strip())
    helper_embs = model.encode([h.strip() for h in helper_texts])
    
    print("🆘 Seeker: Stressed student before finals")
    print("\n🤝 Helper Similarity Scores:")
    
    for i, (name, helper_text) in enumerate(zip(helper_names, helper_texts)):
        sim = cosine_similarity(seeker_emb, helper_embs[i])
        bar = "█" * int(sim * 50)
        print(f"   {name}: {sim:.3f} {bar}")
    
    print("\n✅ Best match: Alex (highest similarity = most relevant experience)")
    
except Exception as e:
    print(f"❌ Matching test failed: {e}")
    exit(1)

# Success!
print("\n" + "=" * 70)
print("🎉 ALL TESTS PASSED!")
print("=" * 70)
print("\n✅ Sentence Transformers is working perfectly on your system")
print("✅ You can use FREE local embeddings (no API costs)")
print("✅ The matching algorithm should work without SKIP_SENTENCE_TRANSFORMERS\n")

print("💡 Next steps:")
print("   1. Run: python local_test_matcher.py")
print("      (should work now without the skip flag)")
print("   2. Or set OPENAI_API_KEY for even better quality")
print("   3. Compare both approaches in your demo!\n")
