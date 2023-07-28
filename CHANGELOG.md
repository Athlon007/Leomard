# Changelog

## 0.4 (2023-07-29)

## Added

- Mod Tools:
    - Remove posts
    - Lock posts
    - Distinguish comment
    - Remove comments
    - Remove community
    - Edit community
- Post-locked indicator
- Distinguished comment indicator
- Instance icons on the login screen
- Search for instance on the login screen
- Search profiles
- Separate followed communities by first letter of the name (disabled by default)
- Prefered display name for communities and users: you can either choose to display handles, or display names
- Search followed communities

### Bug Fixes

- Fixed opening post, if you opened a community from another post
- Fixed login to some instances caused to faulty decoding of site metadata
- Fixed displaying videos, if they are added in "URL" part of the post
- Fixed duplicate posts in communities
- Fixed sorting of followed communities

## 0.3 (2023-07-27)

### Added

- Added support for "!community@instance" and "@user@instance" in the text. You can now click on them to open the community or user profile
- Added protocol handler for `leomard://` links. Communties or profiles can be opened by opening a link with such protocol (example: `leomard://!leomard@lemm.ee`)
- You can now feature a post in community as a moderator (right-click and click "Pin")
- Color coding to subcomments
- Comments can now be marked as read manually, on post view, or vote
- "Show NSFW Content in Feed" toggle
- "Hide Read Posts" toggle
- Cross-posting
- Hide instances. Simply add an instance hostname to the list in settings, and posts, comments and profiles from that instance will not be shown in the feed and search
- Compact View
- Added profile editing
    - You can now change display name and banner in the profile view
    - You can view blocked communities and persons, as well as unblock them
    - To access, go into your profile and click the pen icon
- "Trending" communities when opening Search. You can also scroll down to see more trending communities
- You can now select from saved sessions on login screen

### Changes

- Decreased the indentation of the subcomments
- Decreased the minimum window height, so the window won't be too big on smaller screens or larger display scales
- Slightly lowered system requirements to macOS 13.0 (previous version required was macOS 13.1)

### Bug Fixes

- Fixed verifying URLs in post creation. Sometimes the server would not allow "HEAD" requests. If that's the case, the app will send "GET", if 405 is returned
- Fixed adding images, if they have a space in the name
- Window size is not restored correctly on launch
- Fix duplicate call to updateUnreadMessagesCount() (#54)
- When all replies are shown, when replying, the reply won't disappear (#57)

## 0.2 (2023-07-24)

*Note: You will have to log in again, because the app now uses a different method of storing the authorization tokens. Sorry for the inconvenience.*

### Added

- Added status indicator when sending a post (#7)
- Added alert when sending/editing post/comment fails
- Refreh button in the inbox
- Replies sort method for inbox
- Profile view sort method
- Added status indicator when sending a reply
- Multi-account support (#22)
- Confirm delete post/comment
- Blocking users
- Blocking communities
- Update checking on launch
- Image uploading
- Search within community
- OP indicator in the comments
- Post reporting
- Comment reporting
- Bots are now marked with "🤖" emoji
- Support for "!community@instance" and "@user@instance" in Search

### Changes

- **Massive** refactoring of code and general optimization, thanks to [boscojwho](https://github.com/boscojwho) on GitHub
    - Post views are now a bit prettier
    - Replaced stock AsyncImage with Nuke
    - Improved load time of the app (both from cold start and from background)
    - API request handler is now running in separate thread, which should speed up the app
- 2FA key field is now always present in the login view (seems like some Lemmy instances change the response text when 2FA is enabled, so the app can't reliably detect if 2FA is enabled)
- Many UI improvements

### Bug Fixes

- Fixed notification counter not updating (#9)
- Unread message count should update, as soon as you reply to a message from the inbox
- Post creation popup content never gets cleared (#6)
- Fixed images in comments overflowing the comment box, if the image was placed in line with text
- Fixed duplicate posts and comments

### Removed

- Experimental settings

## 0.1 (2023-07-17)

- Initial release