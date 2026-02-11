enum ConversationMode {
  vent,
  reflect,
  clarity,
  growth,
}

extension ConversationModeExt on ConversationMode {
  String get label {
    switch (this) {
      case ConversationMode.vent:    return 'Vent';
      case ConversationMode.reflect: return 'Reflect';
      case ConversationMode.clarity: return 'Clarity';
      case ConversationMode.growth:  return 'Growth';
    }
  }

  // Kept for backwards compat — returns empty string (emoji removed)
  String get emoji => '';

  String get description {
    switch (this) {
      case ConversationMode.vent:    return 'Share freely — your listener is here';
      case ConversationMode.reflect: return 'Helper mirrors emotions back';
      case ConversationMode.clarity: return 'Gentle prompts to find clarity';
      case ConversationMode.growth:  return "What's one small step forward?";
    }
  }

  String get scaffoldPrompt {
    switch (this) {
      case ConversationMode.vent:
        return 'The seeker needs to be heard. Do not give advice. Just validate and listen. Reply with short, warm acknowledgements.';
      case ConversationMode.reflect:
        return "Mirror the seeker's emotions back to them. Use phrases like 'It sounds like...' or 'I hear that you are feeling...'. Do not problem-solve.";
      case ConversationMode.clarity:
        return 'Ask one gentle open question to help the seeker understand their situation better. Do not rush to solutions.';
      case ConversationMode.growth:
        return 'Collaboratively explore one small, concrete step the seeker could take. Keep it manageable and encouraging.';
    }
  }
}
