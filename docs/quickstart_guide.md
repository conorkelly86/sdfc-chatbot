# Football Club Chatbot - Quick Start Guide

## Running the Chatbot

1. **Start the Docker container**:

   ```bash
   docker-compose up -d
   ```

2. **Enter the container**:

   ```bash
   docker-compose exec rasa bash
   ```

3. **Train the model** (needed after any configuration changes):

   ```bash
   rasa train
   ```

4. **Start the chatbot**:
   ```bash
   rasa shell
   ```

## Common Commands

- **Validate data**:

  ```bash
  rasa data validate
  ```

- **Test NLU model**:

  ```bash
  rasa shell nlu
  ```

- **Interactive learning**:

  ```bash
  rasa interactive
  ```

- **Stop the container**:
  ```bash
  docker-compose down
  ```

## Adding New Features

### 1. Add a new intent:

1. Add examples to `data/nlu/nlu.yml`:

   ```yaml
   - intent: new_intent_name
     examples: |
       - Example phrase 1
       - Example phrase 2
       - Example phrase 3
   ```

2. Add the intent to `domain.yml`:

   ```yaml
   intents:
     - new_intent_name
   ```

3. Add a response in `domain.yml`:

   ```yaml
   responses:
     utter_new_intent_name:
       - text: "Your response text here"
   ```

4. Create a story in `data/stories/stories.yml`:

   ```yaml
   - story: new intent story
     steps:
       - intent: greet
       - action: utter_greet
       - intent: new_intent_name
       - action: utter_new_intent_name
   ```

5. Optionally, add a rule in `data/rules/rules.yml`:

   ```yaml
   - rule: New intent rule
     steps:
       - intent: new_intent_name
       - action: utter_new_intent_name
   ```

6. Retrain the model:
   ```bash
   rasa train
   ```

### 2. Improve intent recognition:

If your bot doesn't recognize certain phrases:

1. Add more varied examples to the intent in `data/nlu/nlu.yml`
2. Include variations and synonyms of key terms
3. Add examples with different sentence structures
4. Retrain and test

## Common Questions

**Q: Why isn't my bot recognizing my questions?**  
A: You may need to add more training examples or adjust the confidence threshold in `config.yml`.

**Q: How do I add buttons or images?**  
A: Modify responses in `domain.yml` to include buttons or image URLs:

```yaml
responses:
  utter_example:
    - text: "Text with buttons"
      buttons:
        - title: "Button 1"
          payload: "/intent_name"
        - title: "Button 2"
          payload: "/other_intent"
    - text: "Text with image"
      image: "https://example.com/image.jpg"
```

**Q: How do I connect to external APIs?**  
A: Implement custom actions in `actions.py` and configure the action server in `endpoints.yml`.

## Troubleshooting

1. **Issue**: Bot doesn't understand variations of questions
   **Solution**: Add more training examples with diverse phrasings

2. **Issue**: Bot responds with "I didn't understand"
   **Solution**: Lower the threshold in the FallbackClassifier configuration

3. **Issue**: Changes not taking effect
   **Solution**: Make sure to run `rasa train` after any changes to configuration files
