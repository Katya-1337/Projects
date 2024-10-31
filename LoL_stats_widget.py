from PyQt5 import QtWidgets, QtGui, QtCore
import asyncio
import sys
import requests  # Assuming requests for synchronous calls to Riot API
import aiohttp  # aiohttp for asynchronous calls


class RiotAPIFetcher(QtWidgets.QWidget):
    def __init__(self):
        super().__init__()

        # UI Setup
        self.setWindowTitle("Riot API Data Fetcher")
        self.setGeometry(100, 100, 600, 400)
        
        # Input fields
        self.game_name_input = QtWidgets.QLineEdit(self)
        self.game_name_input.setPlaceholderText("Enter Game Name (Riot ID)")

        self.tag_line_input = QtWidgets.QLineEdit(self)
        self.tag_line_input.setPlaceholderText("Enter Tag Line")

        self.champion_name_input = QtWidgets.QLineEdit(self)
        self.champion_name_input.setPlaceholderText("Enter Champion Name")

        # Submit button
        self.fetch_button = QtWidgets.QPushButton("Fetch Data", self)
        self.fetch_button.clicked.connect(self.fetch_data)

        # Results display
        self.result_display = QtWidgets.QTextEdit(self)
        self.result_display.setReadOnly(True)

        # Layout
        layout = QtWidgets.QVBoxLayout()
        layout.addWidget(QtWidgets.QLabel("Player Information:"))
        layout.addWidget(self.game_name_input)
        layout.addWidget(self.tag_line_input)
        layout.addWidget(QtWidgets.QLabel("Champion Information:"))
        layout.addWidget(self.champion_name_input)
        layout.addWidget(self.fetch_button)
        layout.addWidget(self.result_display)
        self.setLayout(layout)

    def fetch_data(self):
        # Input values
        game_name = self.game_name_input.text()
        tag_line = self.tag_line_input.text()
        champion_name = self.champion_name_input.text()
        
        # Validate inputs
        if not game_name or not tag_line:
            self.result_display.setText("Please enter both Game Name and Tag Line.")
            return
        
        self.result_display.setText("Fetching data...")
        
        # Run asyncio to manage asynchronous functions
        loop = asyncio.new_event_loop()
        asyncio.set_event_loop(loop)
        loop.run_until_complete(self.fetch_player_and_champion_info(game_name, tag_line, champion_name))

    async def fetch_player_and_champion_info(self, game_name, tag_line, champion_name):
        # Replace with actual API Key
        api_key = "DELETED THE KEY"

        try:
            # Fetch player PUUID
            puuid = await self.get_player_puuid(game_name, tag_line, api_key)
            if puuid:
                # Fetch player stats
                player_info = await self.get_player_info(puuid, api_key)
                
                # Fetch champion stats if champion name is provided
                champion_info = await self.get_champion_info(puuid, champion_name, api_key) if champion_name else {}

                # Display results
                self.display_results(player_info, champion_info)
            else:
                self.result_display.setText("Error: Unable to retrieve player data.")

        except Exception as e:
            self.result_display.setText(f"An error occurred: {e}")

    async def get_player_puuid(self, game_name, tag_line, api_key):
        url = f"https://europe.api.riotgames.com/riot/account/v1/accounts/by-riot-id/{game_name}/{tag_line}"
        headers = {"X-Riot-Token": api_key}

        async with aiohttp.ClientSession() as session:
            async with session.get(url, headers=headers) as response:
                if response.status == 200:
                    data = await response.json()
                    return data.get("puuid")
                else:
                    self.result_display.setText(f"Error: {response.status} fetching PUUID")
                    return None

    async def get_player_info(self, puuid, api_key):
        url = f"https://eun1.api.riotgames.com/lol/summoner/v4/summoners/by-puuid/{puuid}"
        headers = {"X-Riot-Token": api_key}

        async with aiohttp.ClientSession() as session:
            async with session.get(url, headers=headers) as response:
                if response.status == 200:
                    data = await response.json()
                    flex_sr_info = next(
                    (
                        f"{item['tier']} {item['rank']}"
                        for item in data
                        if item["queueType"] == "RANKED_FLEX_SR"
                    ),
                    "Not found",
                    )
                    solo_5x5_info = next(
                    (
                        f"{item['tier']} {item['rank']}"
                        for item in data
                        if item["queueType"] == "RANKED_SOLO_5x5"
                    ),
                    "Not found",
                    )
                    return flex_sr_info, solo_5x5_info
                else:
                    return {"error": f"Failed to fetch player info: {response.status}"}

    async def get_champion_info(self, puuid, champion_name, api_key):
        url = f"https://eun1.api.riotgames.com/lol/champion-mastery/v4/champion-masteries/by-puuid/{puuid}"
        headers = {"X-Riot-Token": api_key}

        async with aiohttp.ClientSession() as session:
            async with session.get(url, headers=headers) as response:
                if response.status == 200:
                    # Filtering champion data
                    champion_data = await response.json()
                    for champion in champion_data:
                        if champion.get("championName") == champion_name:
                            return {
                                "championLevel": champion.get("championLevel"),
                                "championPoints": champion.get("championPoints"),
                                "lastPlayTime": champion.get("lastPlayTime"),
                            }
                    return {"error": "Champion not found in mastery data"}
                else:
                    return {"error": f"Failed to fetch champion info: {response.status}"}

    def display_results(self, player_info, champion_info):
        output = f"Player Information:\n"
        if 'error' in player_info:
            output += f"{player_info['error']}\n"
        else:
            output += f"Summoner Level: {player_info['summonerLevel']}\n"
            output += f"Flex SR Info: {player_info['flex_sr_info']}\n"
            output += f"Solo 5x5 Info: {player_info['solo_5x5_info']}\n"

        output += "\nChampion Information:\n"
        if 'error' in champion_info:
            output += f"{champion_info['error']}\n"
        else:
            output += f"Champion Level: {champion_info.get('championLevel', 'N/A')}\n"
            output += f"Champion Points: {champion_info.get('championPoints', 'N/A')}\n"
            output += f"Last Play Time: {champion_info.get('lastPlayTime', 'N/A')}\n"

        self.result_display.setText(output)


# Run the application
app = QtWidgets.QApplication(sys.argv)
window = RiotAPIFetcher()
window.show()
sys.exit(app.exec_())
