Game Theory
===========

In order to start your implementation, you can use the dumb bot [Bot_Coop.py](https://github.com/vjeux/GameTheory/blob/master/bots/bot_coop.py) as a base. It's written in Python.

Example
=======

```ruby
# Players: Vjeux, Gauth, Felix

< Welcome! Please wait for a new game to start.

< Start
> Vjeux    # We send our player name
< Vjeux-0  # We receive a unique player name

< Prisonnier # Let's start a Prisonnier round
< Vjeux-0 Gauth-1 Felix-2 # We receive the list of players
> Gauth-1=T Felix-2=C # We send our decision about all the players
< Gauth-1=T Felix-2=T # We receive the decision of all the players about us

< Pirate # Let's start a Pirate round
< 30 Gauth-1 Vjeux-0 Felix-2 # We receive the bounty along with the players sorted by hierarchy
< Gauth-1=10 Vjeux-0=10 Felix-2=10 # We receive Gauth-1 share of the bounty
> T # We do not agree, we decide to betray him

< Pirate # Gauth-0 has died, another round of Pirate
< 30 Vjeux-0 Felix-2 # We are now the leader
> Vjeux-0=30 Felix-2=0 # We send the shares

< 30 # We win the full bounty!

< Prisonnier # Another round of Prisonnier
< Vjeux-0 Felix-2 # Gauth-1 has been kicked for a round
> Felix-2=T # We betray Felix-2
< Felix-2=T # He betrays us too

< 0 # There is no Pirate round since we are alone in our group. We receive a bounty of 0.

< End # There was only 2 Prisonnier round
< Vjeux-0=30 Felix-2=0 Gauth-1=0 # We receive the scores of everyone
```

Messages
========

* There's a ```\r\n``` at the end of each message.
* Multiple arguments are space separated and key-values are separated by an ```=``` character.
* If you send a non-valid message, timeout, disconnect... You are going to get assigned a default value.
  * **Name**: ```Unnammed```.
  * **Prisonnier**: You betray ```T``` everyone by default.
  * **Pirate-Leader**: You give all the bounty to yourself, nothing for the others.
  * **Pirate-Non-Leader**: You cooperate ```C``` with the leader.
