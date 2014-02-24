TwitchPlaysX
============

A package that lets you setup your own "Twitch Plays Pokemon" style stream

Hi, anyone from Reddit. Sorry if this submission doesn't fit the guidelines. I thought it was applicable though.

This relies on IRC.pas (which you can find on my github profile)

[Download Windows EXE](https://dl.dropboxusercontent.com/u/33727415/TPX.exe)
====================

Setup Instructions
==================
1. Download / Compile / Run the tool
2. Type the game name into the options
3. Type key mappings into the list (+ button to create new mapping. Type a string that the users will say, and map it to a virtual key code)
4. Select a window in the list to the right. Not all windows are supported, due to GDI limitations. :(
5. Type your twitch username into the channel box and hit connect.
6. Point your streaming application at the TwitchPlaysX window and everything is go. (Theoretically anyway. I've hardly done any testing at all)
7. Have fun.

Compiling Instructions
======================
1. Grab [IRC](https://github.com/SuperDisk/IRC) and put it in the directory
2. Install Fcl-Stl (it's in the source folder of FPC. Compile and copy to units)
3. Open .lpi in Lazarus
4. Build
5. Yay
