<div align="center">
   <img src= "https://gitlab.com/rangerofgondor/video-call/-/raw/master/assets/Icon Black.png" height=100> 
   <img src= https://gitlab.com/rangerofgondor/video-call/-/raw/master/assets/Logo.png height=100>

# Socket Video Call

[![Made with Flutter][flutterdart]][flutter] [![Open Source Love][opensource]]() [![PR][PRs]]() [![Download][Download]][Download-Link] [![GPLv3 license][GPLv3]][License]

### An Android Application, made with Flutter :heart:, to implement video calling between peers on a Local Area Network (LAN), without a Server interaction.
This App is based on WebRTC with concept of Server-less Communication.

</div>

# Screenshots

![Ss1][SS1]
![SS2][SS2]

# Basic Concept

To implement a WebRTC communication we need a server to validate the SDP messages.
Since it's a P2P communication on a LAN, we can exchange SDP messages on our own, than using a server.
Hence, we use a simple TCP messaging on a specific port to send and listen for any communication and transfer the SDP messages.

# Working

- The Caller first initiates a call to a person by createOffer() method of WebRTC.
- Then the SDP message is sent to the peer by communicating through a port the peer is listening.
- The peer gives an Accept/Reject screen to the Callee.
- If the Callee accepts, then the SDP reply is sent back to the Caller.
- This will initiate the WebRTC call.

### Implementation Details

###### A Server and Client communicate with each other in the following manner

<details>
<summary>Server</summary>

#### A Server to listen on a port and handle incoming connections.

###### Steps followed by the server:

1) Initiate a port listen.
2) Send a `HELLO` command with User info (Name) to every incoming connection, wait for a `HELLO` command reply with info (Name).
3) Wait for a `CALL` command reply from client, if it's a scan for available peers, the client might close connection.
4) Next Action:
   - If user is already on a call, send a `BUSY` command and close.
   - Initiate a Incoming call screen to display to the user.
   - If user REJECTs the call, send `REJECT` command, and close.
   - If user ACCEPTs the call, send `ACCEPT` command.
5) Initiate RTC and then wait for the `SDP` command with SDP info from the client.
6) Send user SDP info to client with `SDP` command.
7) Wait for `DONE` command and send `DONE` command and close the connection.

</details>

<details>
    <summary>Client</summary>

#### A Client to initiate a connection on a listening port of the peer.

###### Steps followed by the client:

1) Initiate a connect to the server with the specified port no.
2) Send a `HELLO` command with User info (Name), Wait for a `HELLO` command reply with info (Name).
3) Send a `CALL` command.
4) Wait for a reply command:
   - `BUSY` / `REJECT`  command - inform user and close connection.
   - `ACCEPT` command - continue.
5) Initiate RTC and send the `SDP` command with SDP info.
6) Wait for `SDP` command of server with SDP info.
7) Send the `DONE` command and Wait for `DONE` command from server and close the connection.

</details>

# Contribution Guide

This project is open to any and all kinds of contribution in all of its categories.
For feature contribution, create a merge request with the feature as a banch and raise a Merge-Request.
If you have any bug report / suggestion for the project, feel free to open an issue and discuss.


#### Show some :heart: and :star: the repo to support the project!

If you found this project useful, then please consider giving it a :star: on Gitlab and sharing it with your friends via social media.


# Project Created & Maintained By

### Ranger Of Gondor ( Shrivathsa Prakash ✌ )

Freelancer, Flutter Developer, Android Developer, Gopher!

[![Linkedin][linkedin-badge]][linkedin] [![Portfolio Website][portfolio-badge]][portfolio]

### Maths Lover ( Maintainer and Contributer )

[![][mathslover-badge]][mathslover]

# Donate

If you found this project helpful or you learned something from the source code and want to thank me, consider buying me a cup of :coffee:

[![PayPal][PayPal-badge]][PayPal]

# Licence

```
Copyright @ 2020 Shrivathsa Prakash - GPL Version 3

                    GNU GENERAL PUBLIC LICENSE
                       Version 3, 29 June 2007

 Copyright (C) 2007 Free Software Foundation, Inc. <http://fsf.org/>
 Everyone is permitted to copy and distribute verbatim copies
 of this license document, but changing it is not allowed.

```
[flutter]: https://flutter.dev "Flutter"

[Logo]: https://gitlab.com/rangerofgondor/video-call/-/raw/master/assets/Logo.png
[SS1]: https://gitlab.com/rangerofgondor/video-call/-/raw/master/assets/Screenshots/socket-1.png
[SS2]: https://gitlab.com/rangerofgondor/video-call/-/raw/master/assets/Screenshots/socket-2.png
[Download-Link]: https://gitlab.com/rangerofgondor/video-call/-/raw/master/apks/Socket-Video-Call-v1.5.apk
[License]: https://lbesson.GPLv3-license.org

[flutterdart]: https://img.shields.io/badge/flutter-dart-blue?logo=flutter
[flutterdart]: https://img.shields.io/badge/flutter-dart-blue?logo=flutter
[opensource]: https://badges.frapsoft.com/os/v1/open-source.png?v=103
[PRs]: https://img.shields.io/badge/Contributions-Welcome-pink?logo=gitlab
[Download]: https://img.shields.io/badge/Download-APK-green
[GPLv3]: https://img.shields.io/badge/License-GPL%20v3-orange.svg

[portfolio]: https://rangerofgondor.gitlab.io/profile
[linkedin]: https://linkedin.com/in/shrivathsa-prakash
[PayPal]: https://www.paypal.me/rangerofgondor

[mathslover]: https://gitlab.com/maths_lover/

[linkedin-badge]: https://img.shields.io/badge/Linked-In-blue?logo=linkedin
[portfolio-badge]: https://img.shields.io/badge/Portfolio-Website-blueviolet
[mathslover-badge]: https://img.shields.io/badge/maths-lover-orange?logo=gitlab
[PayPal-badge]: https://img.shields.io/badge/Pay-Pal-blue?logo=paypal

