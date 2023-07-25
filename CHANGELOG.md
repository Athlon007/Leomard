# Changelog

## 0.3 (TBA)

### Added

- Added support for "!community@instance" and "@user@instance" in the text
- Added protocol handler for `leomard://` links
- You can now feature a post in community as a moderator (right-click and click "Pin")
- Color coding to subcomments
- Comments can now be marked as read manually, on post view, or vote
- "Show NSFW Content in Feed" toggle

### Changes

- Decreased the indentation of the subcomments

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