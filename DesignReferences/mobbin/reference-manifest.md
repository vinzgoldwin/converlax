# Speak Mobbin Reference Manifest

Date: 2026-05-14

Reference flow URL:
https://mobbin.com/apps/speak-ios-4d06786f-324a-4f57-8f7b-4bdff0f213b2/9ec2d4e8-446d-49d4-8d04-9ed5363e8d05/flows

The requested Chrome plugin is listed as available in the environment, but this session does not expose a callable `chrome` namespace. Reference collection therefore used the Mobbin MCP search capability and direct Mobbin MCP image URLs. Saved files are local reference evidence for implementation audit only.

## Flow Mapping

| Requested flow | Local reference file | Mobbin screen id | Source URL |
| --- | --- | --- | --- |
| Onboarding | `onboarding/speak-language-choice.jpg` | `7f0cd367-2e06-40fd-9573-aea98e08bed1` | https://mobbin.com/screens/7f0cd367-2e06-40fd-9573-aea98e08bed1 |
| Home | `home/speak-home.jpg` | `904c704e-930c-4310-8dc1-bafbf73e9fe6` | https://mobbin.com/screens/904c704e-930c-4310-8dc1-bafbf73e9fe6 |
| Course | `course/speak-course-detail.jpg` | `549d0d79-ddef-43f1-8c65-db20fbf644ee` | https://mobbin.com/screens/549d0d79-ddef-43f1-8c65-db20fbf644ee |
| Chatting with Tutor | `chatting-with-tutor/speak-tutor-chat.jpg` | `84573c60-48ee-428c-9cf7-c0ad14ddf7f2` | https://mobbin.com/screens/84573c60-48ee-428c-9cf7-c0ad14ddf7f2 |
| Completing a vocab lesson | `completing-vocab-lesson/speak-voice-lesson-prompt.jpg` | `81f174a7-a929-4520-b6df-eb43dcbed8af` | https://mobbin.com/screens/81f174a7-a929-4520-b6df-eb43dcbed8af |
| Completing verb lesson | `completing-verb-lesson/speak-free-talk-feedback.jpg` | `d9115641-90f3-4ee4-9ee7-fff6cdf1c5ac` | https://mobbin.com/screens/d9115641-90f3-4ee4-9ee7-fff6cdf1c5ac |
| Selecting a level | `selecting-a-level/speak-level-selection.jpg` | `3de1921e-7f9c-4db7-8852-06580aef1cfc` | https://mobbin.com/screens/3de1921e-7f9c-4db7-8852-06580aef1cfc |
| Streak | `streak/speak-profile-streak-calendar.jpg` | `b1802d44-e332-4130-bbf4-f195931c7bd1` | https://mobbin.com/screens/b1802d44-e332-4130-bbf4-f195931c7bd1 |
| Free Talk | `free-talk/speak-free-talk-session.jpg` | `711a9276-9b9d-4fa3-8926-f754d17b4087` | https://mobbin.com/screens/711a9276-9b9d-4fa3-8926-f754d17b4087 |
| Creating a roleplay lesson | `creating-roleplay-lesson/speak-create-own-entry.jpg` | `dc67a3c2-8238-4b19-9458-43dc6cc97a93` | https://mobbin.com/screens/dc67a3c2-8238-4b19-9458-43dc6cc97a93 |
| Topics | `topics/speak-topics-roleplay-grid.jpg` | `dc67a3c2-8238-4b19-9458-43dc6cc97a93` | https://mobbin.com/screens/dc67a3c2-8238-4b19-9458-43dc6cc97a93 |
| Roleplay detail | `roleplay-detail/speak-roleplay-detail.jpg` | `8e6149f0-02f6-4b24-b8fa-029f51b26f3d` | https://mobbin.com/screens/8e6149f0-02f6-4b24-b8fa-029f51b26f3d |
| History & usage | `history-usage/speak-conversation-transcript.jpg` | `d9115641-90f3-4ee4-9ee7-fff6cdf1c5ac` | https://mobbin.com/screens/d9115641-90f3-4ee4-9ee7-fff6cdf1c5ac |
| Favorites | `favorites/speak-favorites-button.jpg` | `dc67a3c2-8238-4b19-9458-43dc6cc97a93` | https://mobbin.com/screens/dc67a3c2-8238-4b19-9458-43dc6cc97a93 |
| Community | `community/speak-community-list.jpg` | `810440ad-c697-4e49-835d-99fd668a049e` | https://mobbin.com/screens/810440ad-c697-4e49-835d-99fd668a049e |
| Profile | `profile/speak-profile.jpg` | `b1802d44-e332-4130-bbf4-f195931c7bd1` | https://mobbin.com/screens/b1802d44-e332-4130-bbf4-f195931c7bd1 |
| Saved lines | `saved-lines/speak-saved-lines-profile-entry.jpg` | `353ab146-47df-4069-bda9-5e6dd00c0293` | https://mobbin.com/screens/353ab146-47df-4069-bda9-5e6dd00c0293 |
| Activities | `activities/speak-activity-log.jpg` | `353ab146-47df-4069-bda9-5e6dd00c0293` | https://mobbin.com/screens/353ab146-47df-4069-bda9-5e6dd00c0293 |
| Settings | `settings/speak-settings.jpg` | `1fb448ff-a856-476f-b8de-f91a4b6d67fe` | https://mobbin.com/screens/1fb448ff-a856-476f-b8de-f91a4b6d67fe |

## Reference Notes

- Some requested Converlax flows map to the same Speak screen because Speak combines their entry points in one surface, such as Topics, Create your own, Favorites, and roleplay grid navigation.
- `Completing verb lesson` uses a Speak feedback/transcript completion reference because Mobbin search returned a direct lesson-feedback sequence rather than a dedicated verb-only flow screen.
- `Activities` uses the profile activity-log reference, which is the visible Speak location for activity state in the returned reference set.
