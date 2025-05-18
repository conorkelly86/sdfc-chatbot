# Football Club Chatbot

A Rasa-based chatbot for a football club.

## Getting Started

### Using Docker (Recommended)

1. Build the Docker container:

   ```
   docker-compose build
   ```

2. Start the container:

   ```
   docker-compose up -d
   ```

3. Enter the container to run Rasa commands:

   ```
   docker-compose exec rasa bash
   ```

4. Inside the container, you can initialize a new Rasa project:

   ```
   rasa init
   ```

5. Train the model:

   ```
   rasa train
   ```

6. Run the chatbot:

   ```
   rasa shell
   ```

7. When done, stop the container:
   ```
   docker-compose down
   ```

## Project Structure

The Rasa project structure will be created when you run `rasa init` inside the container. It will include:

- `actions/`: Custom actions code
- `data/`: Training data (NLU data, stories)
- `models/`: Trained model files
- `config.yml`: Model configuration
- `domain.yml`: Domain definition
- `endpoints.yml`: Endpoints configuration
