# Implementing Custom Actions

Custom actions allow your chatbot to interact with external systems, APIs, and databases to provide dynamic responses based on real-time data.

## Setting Up Custom Actions

### 1. Create an actions.py file

```python
from typing import Any, Text, Dict, List
from rasa_sdk import Action, Tracker
from rasa_sdk.executor import CollectingDispatcher
from rasa_sdk.events import SlotSet

class ActionCheckMatchSchedule(Action):
    """Fetch real match schedule from an API."""

    def name(self) -> Text:
        return "action_check_match_schedule"

    def run(self, dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:

        # Here you would make an API call to get real match data
        # For demonstration, we're using hardcoded data

        match_details = {
            "opponent": "Manchester United",
            "location": "Home Stadium",
            "date": "Next Saturday",
            "time": "3:00 PM"
        }

        message = f"Our next match is against {match_details['opponent']} at {match_details['location']} on {match_details['date']} at {match_details['time']}."

        dispatcher.utter_message(text=message)

        return [SlotSet("match_date", match_details['date'])]
```

### 2. Update endpoints.yml

Uncomment the action_endpoint section:

```yaml
action_endpoint:
  url: "http://localhost:5055/webhook"
```

### 3. Update domain.yml

Add the custom action to your domain file:

```yaml
actions:
  - action_check_match_schedule
```

### 4. Update stories.yml

Update your story to use the custom action:

```yaml
- story: check match schedule
  steps:
    - intent: greet
    - action: utter_greet
    - intent: match_schedule
    - action: action_check_match_schedule
```

### 5. Running the Action Server

Run the action server in a separate terminal:

```bash
rasa run actions
```

## Example Custom Actions

### 1. Fetching Player Statistics

```python
class ActionPlayerStats(Action):
    def name(self) -> Text:
        return "action_player_stats"

    def run(self, dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:

        # Extract the player name from the conversation
        player_name = tracker.get_slot("player_name")

        if not player_name:
            dispatcher.utter_message(text="Which player would you like to know about?")
            return []

        # Here you would call a database or API to get player stats
        # For demonstration, we're using hardcoded data

        # Simple player database
        players = {
            "James Smith": {
                "position": "Forward",
                "goals": 12,
                "assists": 8,
                "age": 27
            },
            "Kevin Jones": {
                "position": "Midfielder",
                "goals": 5,
                "assists": 15,
                "age": 24
            }
        }

        if player_name in players:
            player = players[player_name]
            message = f"{player_name} is a {player['age']}-year-old {player['position']} who has scored {player['goals']} goals and provided {player['assists']} assists this season."
            dispatcher.utter_message(text=message)
        else:
            dispatcher.utter_message(text=f"I don't have information about {player_name}. Would you like to know about another player?")

        return []
```

### 2. Weather at the Stadium

```python
class ActionStadiumWeather(Action):
    def name(self) -> Text:
        return "action_stadium_weather"

    def run(self, dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:

        # Here you would call a weather API
        # For demonstration, we're using hardcoded data

        weather = {
            "condition": "Partly Cloudy",
            "temperature": 18,
            "chance_of_rain": 20
        }

        message = f"The weather at our stadium currently is {weather['condition']} with a temperature of {weather['temperature']}°C. There's a {weather['chance_of_rain']}% chance of rain."

        dispatcher.utter_message(text=message)

        return []
```

## Slot Filling and Forms

For more complex interactions like ticket booking, you can use forms:

```python
from rasa_sdk.forms import FormValidationAction
from rasa_sdk.types import DomainDict

class ValidateTicketBookingForm(FormValidationAction):
    def name(self) -> Text:
        return "validate_ticket_booking_form"

    def validate_match_selection(
        self,
        slot_value: Any,
        dispatcher: CollectingDispatcher,
        tracker: Tracker,
        domain: DomainDict,
    ) -> Dict[Text, Any]:
        """Validate match selection."""

        # Check if the match exists
        available_matches = ["Manchester United (Home)", "Liverpool (Away)", "Arsenal (Home)"]

        if slot_value.lower() not in [match.lower() for match in available_matches]:
            dispatcher.utter_message(text=f"Sorry, I couldn't find a match against {slot_value}. Available matches are: {', '.join(available_matches)}")
            return {"match_selection": None}

        return {"match_selection": slot_value}

    def validate_ticket_quantity(
        self,
        slot_value: Any,
        dispatcher: CollectingDispatcher,
        tracker: Tracker,
        domain: DomainDict,
    ) -> Dict[Text, Any]:
        """Validate ticket quantity."""

        # Convert to integer and validate
        try:
            quantity = int(slot_value)
            if quantity < 1:
                dispatcher.utter_message(text="You need to book at least one ticket.")
                return {"ticket_quantity": None}
            if quantity > 10:
                dispatcher.utter_message(text="You can book a maximum of 10 tickets at once.")
                return {"ticket_quantity": None}
            return {"ticket_quantity": quantity}
        except ValueError:
            dispatcher.utter_message(text="Please provide a valid number of tickets.")
            return {"ticket_quantity": None}
```

## Connecting to External APIs

For connecting to real APIs, use the `requests` library:

```python
import requests

class ActionLiveScores(Action):
    def name(self) -> Text:
        return "action_live_scores"

    def run(self, dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:

        try:
            # Replace with a real API endpoint
            response = requests.get("https://api.football-data.org/v2/matches",
                                    headers={"X-Auth-Token": "YOUR_API_KEY"})

            if response.status_code == 200:
                data = response.json()
                # Process the data and create a response
                matches = data.get("matches", [])

                if not matches:
                    message = "There are no live matches at the moment."
                else:
                    message = "Current live scores:\n"
                    for match in matches[:5]:  # Show only first 5 matches
                        home_team = match["homeTeam"]["name"]
                        away_team = match["awayTeam"]["name"]
                        score = f"{match['score']['fullTime']['homeTeam']} - {match['score']['fullTime']['awayTeam']}"
                        message += f"{home_team} vs {away_team}: {score}\n"

                dispatcher.utter_message(text=message)
            else:
                dispatcher.utter_message(text="Sorry, I couldn't fetch the live scores at the moment.")

        except Exception as e:
            dispatcher.utter_message(text="Sorry, there was an error fetching the live scores.")
            print(f"Error: {e}")

        return []
```

## Starting with Custom Actions

1. Create the `actions` directory if it doesn't exist:

   ```bash
   mkdir -p actions
   ```

2. Create the initial `actions.py` file:

   ```bash
   touch actions/__init__.py
   touch actions/actions.py
   ```

3. Update `domain.yml` to include custom actions:

   ```yaml
   actions:
     - action_check_match_schedule
     - action_player_stats
     - action_stadium_weather
   ```

4. Start the action server:

   ```bash
   rasa run actions
   ```

5. In a separate terminal, run the Rasa server:
   ```bash
   rasa shell
   ```

## Best Practices

1. **Error Handling**: Always wrap API calls in try-except blocks
2. **Input Validation**: Validate user inputs before using them in external calls
3. **Feedback**: Provide clear feedback about what's happening
4. **Fallbacks**: Have fallback responses when data can't be retrieved
5. **Logging**: Log errors and activity for monitoring
6. **Security**: Keep API keys and credentials secure (use environment variables)

Happy coding!
