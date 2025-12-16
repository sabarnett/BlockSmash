# SpriteKit Games
I've written a couple if games apps; one for the MAC and one for the iPad. Both were relatively simple, low graphics game compendiums. While they were fun to write and I still play them now, there was nothing __arcade__ about them. The graphics content was just enough to make the game look good.

I felt the urge to make something more graphical and Apple's 2D graphical game engine is the old (very old)
SpriteKit framework. So I figured I should have a go at something more arcade like using SpriteKit.

I started with Paul Hudson's tutorials which game me a basic grounding in SpriteKit and led to four games. The first of these was a space game that has kept me amused and challenged for a while now.

## BlockSmash

BlockSmash is one of those really simple games that quickly becomes addictive. 

![BlockSmash](images/blockSmashiPad.png)

The game is simple, tap on groups of two or more blocks of the same colour. Depending on how many adjacent blocks there are of the same colour, you earn points. The smashed blocks are replaced and the game continues until the timer runs out.

Ok, it is a little more complicated. Clicking on a group of two earns you no points at all. Three gets you points, but not very many. The strategy is to try and build larger blocks which gain you a lot of points. If you hit a single block, the entire board resets to new blocks.

As a bonus, there will occasionally be a bomb. Tapping this matches all adjacent blocks, so there are big points to be had.

The original version of this game was produced by Paul Hudson in his [Dive Into Spritekit](https://www.hackingwithswift.com/store/dive-into-spritekit) book. I extended the game to include;

* A countdown bar that canges colour as time runs out.
* Blocks rather than the original balloons.
* A better background. The previous one was very distracting.
* A toolbar on the right to allow you to turn sound on and off and to pause/restart the game. 
* A high score system that tracks the last 5 highest scores, plus a toolbar icon to display it at any time.

I'm still new to SpriteKit, so don't expect perfect code. Learning takes time!
