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
- `assets/videos/tea-lifestyle.mp4`
- `assets/photos/hero-thumbnail-bg.png`
- `assets/photos/launch-lifestyle-bg.png`
- `assets/photos/scanner-package-bg.png`
- `assets/photos/warm-tea-table-bg.png`

No `logo/` folder or app screenshots were present in the supplied campaign asset folder, so this page includes a local fallback SVG app icon at `assets/logo/teatimer-icon.svg`.

## App Screenshots

Place real screenshots here when available:

```text
marketing/landing-page/assets/app-screenshots/
```

Suggested filenames:

- `home-timer.png`
- `scan-tea.png`
- `saved-teas.png`
- `diary-reviews.png`

Then replace the placeholder phone markup in `index.html` inside the `#preview` section with `<img>` tags pointing to those files.

## Editing Copy

Edit visible text in `index.html`. The main sections are:

- Hero
- App preview
- Features
- How it works
- Lifestyle
- Final CTA / waitlist

Styling lives in `style.css`. The color system is defined at the top under `:root`.

## Not Connected Yet

The waitlist form has no backend or email capture service. It validates the email field visually and opens a `mailto:` message to `hello@teatimer.app`.

To connect real capture later, replace the submit handler in `script.js` with a request to your backend, newsletter provider, or form service.
