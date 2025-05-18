# Football Club Chatbot - Project Documentation

## Table of Contents

1. [Project Overview](#project-overview)
2. [Environment Setup](#environment-setup)
3. [Project Structure](#project-structure)
4. [Chatbot Configuration](#chatbot-configuration)
5. [NLU Data](#nlu-data)
6. [Conversation Flows](#conversation-flows)
7. [Rules](#rules)
8. [Responses](#responses)
9. [Troubleshooting](#troubleshooting)
10. [Next Steps](#next-steps)

## Project Overview

This project implements a conversational AI chatbot for a football club using Rasa framework. The chatbot can answer questions about:

- Match schedules
- Ticket information
- Player information
- Team performance
- Stadium details

## Environment Setup

The project uses Docker to create an isolated environment with the correct dependencies:

1. **Docker Environment**: Created a Docker container with Python 3.8 and installed Rasa and TensorFlow.

   - Used a `Dockerfile` with necessary dependencies
   - Set up `docker-compose.yml` for easy container management

2. **Running the Container**:

   ```bash
   docker-compose build   # Build the container
   docker-compose up -d   # Start the container in detached mode
   docker-compose exec rasa bash  # Enter the container
   ```

3. **Training the Model**:

   ```bash
   rasa train  # From within the container
   ```

4. **Starting the Bot**:
   ```bash
   rasa shell  # Interactive shell for testing
   ```

## Project Structure

```
football-club-chatbot/
├── config.yml           # NLU and policy configuration
├── domain.yml           # Domain file with intents, entities, slots, responses
├── data/
│   ├── nlu/             # Natural Language Understanding data
│   │   └── nlu.yml      # Intent examples and entity annotations
│   ├── stories/         # Conversation flow definitions
│   │   └── stories.yml  # Training stories for the dialogue model
│   └── rules/           # Rule-based conversation patterns
│       └── rules.yml    # Rules for specific behavior patterns
├── endpoints.yml        # Connection endpoints configuration
├── Dockerfile           # Docker configuration
├── docker-compose.yml   # Docker Compose configuration
└── docs/                # Documentation
```

## Chatbot Configuration

The `config.yml` file configures the NLU pipeline and policies:

```yaml
language: en

pipeline:
  - name: WhitespaceTokenizer
  - name: RegexFeaturizer
  - name: LexicalSyntacticFeaturizer
  - name: CountVectorsFeaturizer
  - name: CountVectorsFeaturizer
    analyzer: "char_wb"
    min_ngram: 1
    max_ngram: 4
  - name: DIETClassifier
    epochs: 100
    constrain_similarities: true
  - name: EntitySynonymMapper
  - name: ResponseSelector
    epochs: 100
  - name: FallbackClassifier
    threshold: 0.6
    ambiguity_threshold: 0.1

policies:
  - name: MemoizationPolicy
  - name: TEDPolicy
    max_history: 5
    epochs: 100
  - name: RulePolicy
    core_fallback_threshold: 0.3
    core_fallback_action_name: "action_default_fallback"
    enable_fallback_prediction: true
```

Adjustments made:

- Added FallbackClassifier with a threshold of 0.6 to handle similar questions
- Set constrain_similarities to true for better intent recognition
- Configured RulePolicy with fallback settings

## NLU Data

The NLU data in `data/nlu/nlu.yml` contains example phrases for each intent:

### Implemented Intents

1. **greet**: Greetings and hello messages
2. **goodbye**: Farewell messages
3. **affirm**: Positive confirmations
4. **deny**: Negative responses
5. **thank**: Expressions of gratitude
6. **bot_challenge**: Questions about the bot's identity
7. **match_schedule**: Questions about upcoming matches
8. **ticket_info**: Questions about tickets
9. **player_info**: Questions about players
10. **team_performance**: Questions about team statistics
11. **stadium_info**: Questions about the stadium

### Entity Examples

- **player_name**: Names of players (e.g., "Tell me about [James Smith](player_name)")
- **match_date**: Dates of matches
- **team_name**: Names of teams

## Conversation Flows

Conversation flows are defined in `data/stories/stories.yml`:

1. **greet and match schedule**: User greets → Bot responds → User asks about matches → Bot provides schedule
2. **greet and ticket info**: User greets → Bot responds → User asks about tickets → Bot provides ticket info
3. **greet and team performance**: User greets → Bot responds → User asks about team → Bot provides team info
4. **greet and player info**: User greets → Bot responds → User asks about player → Bot provides player info
5. **greet and stadium info**: User greets → Bot responds → User asks about stadium → Bot provides stadium details

## Rules

Rules for specific behaviors are defined in `data/rules/rules.yml`:

1. **Say goodbye**: Respond with goodbye message when user says goodbye
2. **Bot identity**: Respond with bot identity when challenged about being a bot
3. **Thank user**: Respond with acknowledgment when user says thanks
4. **Stadium info**: Provide stadium information whenever user asks about the stadium

## Responses

The chatbot's responses are defined in `domain.yml`:

```yaml
responses:
  utter_greet:
    - text: "Hello! I'm your football club assistant. How can I help you today?"

  utter_goodbye:
    - text: "Goodbye! Thanks for chatting with me."

  utter_thank:
    - text: "You're welcome! Is there anything else I can help you with?"

  utter_default:
    - text: "I'm sorry, I didn't understand that. Could you rephrase?"

  utter_iamabot:
    - text: "I am a bot, powered by Rasa. I'm here to help you with information about our football club."

  utter_ask_match_schedule:
    - text: "Our next match is on Saturday at 3 PM against Manchester United at home."

  utter_ticket_info:
    - text: "Tickets for our home games can be purchased online or at the stadium ticket office. Prices range from $30 to $100 depending on the seat location."

  utter_player_info:
    - text: "We have information about many players in our team. Which player would you like to know about?"

  utter_team_performance:
    - text: "Our team is currently in 3rd place in the league with 65 points from 30 games played."

  utter_stadium_info:
    - text: "Our stadium is located at Drum East, Tonabrocky, Drum East, Co. Galway, Ireland"
```

## Troubleshooting

Several issues were encountered and resolved:

1. **Installation Issues**: Used Docker to resolve Python version compatibility issues
2. **Intent Recognition Problems**:

   - Added more varied training examples to improve recognition
   - Added a FallbackClassifier with lower threshold
   - Created specific rules for important intents
   - Adjusted policy configuration

3. **Common Solutions**:
   - When the bot doesn't recognize queries, add more examples to the training data
   - Always retrain the model after making changes to any configuration files
   - Use `rasa data validate` to check for configuration errors
   - Monitor confidence scores to adjust thresholds appropriately

## Next Steps

Potential improvements for the chatbot:

1. **Custom Actions**: Implement custom actions to integrate with external APIs for real-time data
2. **Forms**: Add forms for collecting user information (e.g., ticket booking details)
3. **Rich Responses**: Add buttons, images, and other rich content to responses
4. **Entities Handling**: Implement more sophisticated entity handling for detailed player information
5. **Knowledge Base**: Add a knowledge base connector for complex information retrieval
6. **Testing & Evaluation**: Implement systematic testing and evaluation of the chatbot
7. **Deployment**: Configure a production deployment with appropriate monitoring

---

This documentation was created on: [Current Date]
