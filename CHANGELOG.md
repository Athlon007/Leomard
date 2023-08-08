# Changelog

## 0.5.1 (TBA)

### Bug Fixes

- Fixed crash caused by text editor accessing index out of bounds
- Fixed text editor inserting unexpected "-", if you wrote words with "-" in them and pressed "Return"

## 0.5 (2023-08-08)

### Added

- Two-column view
    - Posts will open in the second column, instead of a popup window
    - You can enable it in Preferences -> Display -> Two-column view
- The "!leomard@lemm.ee" in About view now opens the community in Leomard
- Add "v" symbol to the right of comment, that doubles as Context Menu button for this comment
- Add "Are you sure you want to close post creation" alert
- Community modlog
- Posts can now be marked as read when you scroll past them (disabled by default)
- Add "Display" preferences
- "Show Communities Instances" in Preferences -> Display

### Changes

- Big improvements to Post editor:
    - Added a toolbar with buttons for formatting
    - If you create a list or quote and press "Return", the next line will automatically start with the same formatting
    - Text editor itself now shows formatting as you type
- Updated the About to include HighlightedTextEditor license
- Comment creator, profile sidebar editor and community sidebar editor now use the same text editor
- Sort types dropdown text is now formatted correctly
- General UI consistency improvements
- Moved "Compact View" into "Display" preferences
- Moved "Show Letter Separators" into "Display" preferences

### Bug Fixes

- Fixed an issue where sometimes not all comments would load
- Fixed a bug where if user toggled on compact view, the already loaded posts would not be compacted correctly
- Trending will not show NSFW communities anymore
- Fixed decoding HTML entities in the title of the post
- If compact view is enabled, if you open a post, the bottom bar will not be displayed in a single row anymore

## 0.4.1 (2023-07-30)

### Bug Fixes

- Fixed app crashing when trying to process posts with videos that are NOT on YouTube

## 0.4 (2023-07-29)

### Added

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