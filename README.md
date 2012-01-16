Game Theory
===========

In order to start your implementation, you can use the dumb bot [bot_coop.py](https://github.com/vjeux/GameTheory/blob/master/bots/bot_coop.py) as a base. It's written in Python.

Installation
============

Installation:

```bash
# NodeJS + NPM + CoffeeScript
sudo apt-get install nodejs #https://github.com/joyent/node/wiki/Installing-Node.js-via-package-manager
curl http://npmjs.org/install.sh | sudo sh
sudo npm install -g coffee-script

# Code + Dependencies
git clone git://github.com/vjeux/GameTheory.git
cd GameTheory/server/coffee
npm install async sugar
cd ..
```

Local development:

```bash
# ./run.sh <# of the process to get stdout from> <processes ...>
./run.sh 0 bots/bot_coop.py bots/bot_coop.py bots/bot_coop.py
```

Test your bot against the others (ping me if the server isn't up):

```bash
python bots/yourbot.py fooo.fr 1337
```

Game
====

Phase 1 - [Prisoner's Game](http://en.wikipedia.org/wiki/Prisoner%27s_dilemma)
---------

Each player either Betray ```T``` or Cooperate with ```C``` every other player. It can be seen as a nice complete graph like this:

<img src="http://fooo.fr/~vjeux/epita/game-theory/images/prionnier_1.png" width="400px" />

Those links are used to group players together. We discard every relation but both-sides cooperation ```CC```. Each connected component is a group.

<img src="http://fooo.fr/~vjeux/epita/game-theory/images/prionnier_2.png" width="380px" />

Within each group, we calculate a bounty. It is the sum of all the internal links costs: ```CC``` = 10, ```TC``` = 4 and ```TT``` = 0.

<img src="http://fooo.fr/~vjeux/epita/game-theory/images/prionnier_3.png" width="380px" />

Phase 2 - [Pirate's Game](http://euclid.trentu.ca/math/bz/pirates_gold.pdf)
------

A Pirate's game is started on each group with the previously calculated bounty. Players (now Pirates!) are sorted by score. The one with the biggest score is the Pirate leader. He has to propose a share of the bounty between all the pirates.

<img src="http://fooo.fr/~vjeux/epita/game-theory/images/pirate_1.png" />

Each pirate votes to accept the share or not.

<img src="http://fooo.fr/~vjeux/epita/game-theory/images/pirate_2.png" />

If the leader doesn't get at least half of the votes, he is thrown overboard and the next pirate on the list is now the leader. The fallen leader has to swim back to the ship and therefore will not participate to the next Prisoner's game.

Once a share is approved, the score of each player increases by the amount agreed upon. The server during startup chose a number of rounds, if we didn't reach it yet, a new Prisoner's game starts over.

At the end, the player with the biggest score wins :)

Example
=======

```ruby
# Players: Vjeux, Gauth, Felix

< Welcome! Please wait for a new game to start.

< Start
> Vjeux    # We send our player name
< Vjeux-0  # We receive a unique player name

< Prisoner # Let's start a Prisoner round
< Vjeux-0 Gauth-1 Felix-2 # We receive the list of players
> Gauth-1=C Felix-2=C # We send our decision about all the players
< Gauth-1=T Felix-2=C # We receive the decision of all the players about us

< Pirate # Let's start a Pirate round
< 30 Gauth-1 Vjeux-0 Felix-2 # We receive the bounty along with the players sorted by hierarchy
< Gauth-1=10 Vjeux-0=10 Felix-2=10 # We receive Gauth-1 share of the bounty
> T # We do not agree, we decide to betray him

< Pirate # Gauth-0 has died, another round of Pirate
< 30 Vjeux-0 Felix-2 # We are now the leader
> Vjeux-0=30 Felix-2=0 # We send the shares

< EndPirate
< 30 # We win the full bounty!

< Prisoner # Another round of Prisoner
< Vjeux-0 Felix-2 # Gauth-1 has been kicked for a round
> Felix-2=T # We betray Felix-2
< Felix-2=T # He betrays us too

< EndPirate # There is no Pirate round since we are alone in our group.
< 0 # We receive a bounty of 0.

< EndPrisoner # There was only 2 Prisoner round
< Vjeux-0=30 Felix-2=0 Gauth-1=0 # We receive the scores of everyone
```

Messages
========

* There's a ```\r\n``` at the end of each message.
* Multiple arguments are space separated and key-values are separated by an ```=``` character.
* If you send a non-valid message, timeout, disconnect... You are going to get assigned a default value.
  * **Name**: ```Unnammed```.
  * **Prisoner**: You betray ```T``` everyone by default.
  * **Pirate-Leader**: You give all the bounty to yourself, nothing for the others.
  * **Pirate-Non-Leader**: You cooperate ```C``` with the leader.

