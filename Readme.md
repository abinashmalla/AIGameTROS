# AiGame TROS (The Revenge of Sanosuke)
This Godot3.4 Project is an idle game which graphics and combat inspired from a popular game called Little Fighter 2.

The game doesn't use player inputs, it instead simulates a given number of matches using the same Behavior Tree for both players.
It presents stats at the end. As might be expected, the character who's combos take less combos to get more damage off has the higher winrate.

Disclaimer: I own none of the art assets and credits to authors and source are provided in respective directoriess for such assets.

<u>Controls:</u></br>
Spacebar -> Pause</br>
Enter -> Rematch</br>
S -> Character Stats</br>

In order to run this project, Godot v3.4 stable can be downloaded from here:</br> https://godotengine.org/download/archive/3.4-stable/

The same link also contains export templates for mobile or web platforms.

Project Demo: https://prabeshgiri.com.np/games/tros/ 

## Ending Thoughts
For any future work, being able to play as the characters through a touchscreen or keyboard through the web would be the next step. The project is not well optimized for rollback netcode, and so websockets are the best option for networking.