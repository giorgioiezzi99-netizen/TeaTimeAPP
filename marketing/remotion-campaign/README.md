# TeaTimer Remotion Campaign

Premium vertical launch campaign for the TeaTimer iPhone app.

This project is standalone and isolated from the iOS app. It copies app assets for marketing use, but does not touch signing, provisioning, team settings, bundle identifier, schemes, device settings, or Swift source.

## What It Uses

- Real TeaTimer design cues from `TeaTimerTest/ContentView.swift`.
- Real tea images from `TeaTimerTest/TeaImages`.
- Real app icon from `TeaTimerTest/Assets.xcassets`.
- GPT-generated premium tea lifestyle backgrounds in `public/assets/generated`.
- Remotion TypeScript components and reusable product scenes.
- Reference-style mobile app promo motion documented in `docs/reference-style.md`.

## App Screenshots

Prepare real app screenshots here:

```text
public/app-screenshots
```

Expected filenames:

- `home-screen.png`
- `scanner-screen.png`
- `scan-result-screen.png`
- `edit-scan-screen.png`
- `saved-teas-screen.png`
- `timer-screen.png`
- `review-screen.png`

The current campaign renders with app-faithful Remotion UI recreations, so it does not require screenshots to preview or render.

## Compositions

- `TeaTimerAd15` - 15-second vertical ad.
- `TeaTimerAd30` - 30-second vertical ad.
- `TeaTimerBumper6` - 6-second bumper.
- `TeaTimerThumbnailHero` - still thumbnail concept.
- `TeaTimerThumbnailScanner` - still scanner thumbnail concept.

All video compositions are `1080x1920` at `30fps`.

## Install

```bash
cd marketing/remotion-campaign
npm install
```

## Preview

```bash
cd marketing/remotion-campaign
npm run dev
```

Choose a composition in Remotion Studio.

## Render Videos

```bash
cd marketing/remotion-campaign
npm run render:15
npm run render:30
npm run render:6
```

Outputs:

- `out/teatimer-ad-15s.mp4`
- `out/teatimer-ad-30s.mp4`
- `out/teatimer-bumper-6s.mp4`

## Render Thumbnails

```bash
cd marketing/remotion-campaign
npm run render:thumb:hero
npm run render:thumb:scanner
```

Outputs:

- `out/thumbnail-hero.png`
- `out/thumbnail-scanner.png`

## Quick Layout Check

```bash
cd marketing/remotion-campaign
npm run still:check
```

Output:

- `out/check-frame.png`

## Audio

No copyrighted music is included, and renders do not depend on audio. For publishing, add a licensed calm modern track in the platform editor, or place a licensed file under `public/` and add Remotion's `Audio` component.

Suggested direction: warm minimal piano, soft lo-fi study beat, subtle ceramic cup ambience, or quiet tea-room texture.
