# TeaTimer Landing Page

Static premium landing page for TeaTimer. It is organized as a lightweight GitHub-ready static project and does not require a build step.

## Project Structure

```text
landing-page/
  index.html
  style.css
  script.js
  README.md
  assets/
    app-screenshots/
    logo/
    photos/
    videos/
```

## Open Locally

Open `index.html` in a browser:

```bash
open /Users/giorgioiezzi/Desktop/TeaTimerTest/marketing/landing-page/index.html
```

You can also serve the folder with any static server if you prefer.

## Assets Used

Copied from `marketing/video_campaign_veo_3.1` into `marketing/landing-page/assets`:

- `assets/videos/tea-hero.mp4`
- `assets/photos/hero-thumbnail-bg.png`
- `assets/photos/launch-lifestyle-bg.png`
- `assets/photos/scanner-package-bg.png`
- `assets/photos/thumbnail-hero.png`
- `assets/photos/warm-tea-table-bg.png`

`assets/videos/tea-lifestyle.mp4` is kept in the assets folder for future use but is not currently rendered on the page.

The page also uses the real TeaTimer app icon copied from the iOS asset catalog:

- `assets/logo/teatimer-app-icon.png`

The original fallback SVG icon remains available at `assets/logo/teatimer-icon.svg`, but the page now uses the real app icon.

## App Screenshots

Real app screenshots are used in the preview phones:

```text
marketing/landing-page/assets/app-screenshots/
```

- `home-timer.png`
- `scan-tea.png`
- `saved-teas.png`
- `tea-review.png`

Replace these files with updated screenshots using the same names when you want to refresh the preview.

## Editing Copy

Edit visible text in `index.html`. The main sections are:

- Hero
- App preview
- Features
- How it works
- Final CTA / waitlist

Styling lives in `style.css`. The color system is defined at the top under `:root`.

## Not Connected Yet

The waitlist form has no backend or email capture service. It validates the email field visually and opens a `mailto:` message to `hello@teatimer.app`.

To connect real capture later, replace the submit handler in `script.js` with a request to your backend, newsletter provider, or form service.
