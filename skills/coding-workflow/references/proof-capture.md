# Proof capture

The reviewer should watch the slice work from the PR page alone, without
pulling the branch. So the proof is captured from the slice's final code and
uploaded into the PR itself.

## Pick the proof

| The slice… | Capture |
|---|---|
| adds or reorders steps a user takes | one recording of the whole flow, plus a still of each key screen |
| changes how something looks | a before still and an after still, same viewport, shown side by side |
| fixes a visible bug | a still of the bug on the base branch, and a still of it fixed |
| touches layouts per width or theme | one still per width and theme affected |
| has no screen (API, CLI, job, library) | the command and what it printed, in a fenced code block |
| makes something faster | the number before and after, with the command that measured it |

Map every "done when" item of the slice to one capture.

A recording earns its place only when the path through the app changes: new
steps, new order, new screens. For a restyle, new copy, a new column or one
fixed state, stills say more and take less of the reader's time. One
exception: a bug that only shows while moving (flicker, bad redirect) gets a
recording.

Each still has a red box on the change (see [Red boxes](#red-boxes)).

## Ground rules

- Capture last. Any code change after capture means capture again.
- Fake data only. Before saving, check the frame for real customer data,
  secrets, tokens and personal details, including the address bar, terminal
  history and network panel.
- A recording shows the flow, not the loading: under sixty seconds.
- Files go in `$WORK/evidence/<slice-branch>/`, named for what they show:
  `01-empty-list.png`, `02-email-rejected.png`, `flow.webm`.

## Drive the browser

Start the app with the repo's own start command, and poll until it responds.

**Browser tools in your agent** (for example a Playwright MCP server). Use them to open pages, act
and take stills. For the red box, run the box code below through the evaluate
tool, then take the still. If the tools have no video option, use the script.

**Playwright script.** If the repo has Playwright installed and configured,
use that. Save as `capture.mjs`, swap in your URL, steps and selectors, then
run `PROOF_DIR="$WORK/evidence/<slice-branch>" node capture.mjs`.

```javascript
import { chromium } from 'playwright';

const RED_BOX_ATTRIBUTE = 'data-red-box';
const RED_BOX_GAP_PX = 6;
const VIEWPORT = { width: 1280, height: 800 };

async function screenshotWithRedBoxes(page, filePath, selectors, screenshotOptions = {}) {
  for (const selector of selectors) {
    const element = page.locator(selector).first();
    await element.scrollIntoViewIfNeeded();
    await element.evaluate((node, { attribute, gap }) => {
      const rect = node.getBoundingClientRect();
      const box = document.createElement('div');
      box.setAttribute(attribute, '');
      Object.assign(box.style, {
        position: 'absolute',
        left: `${rect.left + window.scrollX - gap}px`,
        top: `${rect.top + window.scrollY - gap}px`,
        width: `${rect.width + gap * 2}px`,
        height: `${rect.height + gap * 2}px`,
        boxSizing: 'border-box',
        border: '3px solid #ff0033',
        borderRadius: '6px',
        pointerEvents: 'none',
        zIndex: '2147483647',
      });
      document.documentElement.append(box);
    }, { attribute: RED_BOX_ATTRIBUTE, gap: RED_BOX_GAP_PX });
  }
  await page.screenshot({ path: filePath, ...screenshotOptions });
  await page.evaluate((attribute) => {
    document.querySelectorAll(`[${attribute}]`).forEach((box) => box.remove());
  }, RED_BOX_ATTRIBUTE);
}

const outputDir = process.env.PROOF_DIR;
const browser = await chromium.launch();
try {
  const context = await browser.newContext({
    viewport: VIEWPORT,
    recordVideo: { dir: outputDir, size: VIEWPORT },
  });
  const page = await context.newPage();
  await page.goto('http://localhost:5173/login');
  await page.getByLabel('Email').fill('not-an-email');
  await page.getByRole('button', { name: 'Sign in' }).click();
  await screenshotWithRedBoxes(page, `${outputDir}/01-email-rejected.png`, ['[role=alert]']);
  await context.close();
} finally {
  await browser.close();
}
```

- Delete the `recordVideo` line when the user's path did not change.
- The video file appears when the context closes.
- Add `{ fullPage: true }` as the last argument for a full-page still.
- The boxes are removed right after each still, so they never show up in the
  recording.

An existing e2e test for the same flow gives a free recording: run it with
`video: 'on'` in the Playwright config.

Open every still and look at it. A still of a loading spinner, a crash
overlay or some other page misleads more than an empty spot.

No browser possible on this machine? Say so in the PR, and attach the next
best thing: e2e output, raw HTTP responses.

## Red boxes

The reader's eye should land on the change at once.

- Box the tightest element that shows the change: a button, a row, an error
  line. Not its card, not the whole page.
- At most three boxes in one still. More to show? Take another still.
- Before and after stills: box the same spot in both.
- A brand-new page is the change as a whole: no box needed.
- The caption under each still names what the box holds.

Box an image you already have with ffmpeg, given x, y, width and height in
pixels:

```bash
ffmpeg -loglevel error -i 02-total.png -filter:v "drawbox=420:180:320:64:red@1:4" -frames:v 1 -y 02-total-boxed.png
```

Check the result with your own eyes. A box on the wrong element is worse than
none.

## GIF only when needed

GitHub plays uploaded WebM and MP4 in place. Make a GIF only when something
cannot play video:

```bash
ffmpeg -loglevel error -i flow.webm -filter_complex "[0:v]fps=12,scale=900:-2:flags=lanczos,split[frames][copy];[copy]palettegen[palette];[frames][palette]paletteuse" -loop 0 -y flow.gif
```

Target: below 10 MB. Too big? Lower `fps` to 8, then `scale` to 720, then
keep only the part that matters with `-ss <start> -t <seconds>` before `-i`.

## Upload into the PR

From `gh` 2.99.0, `--attach` uploads a file and swaps its local path in the
body for the hosted link. No media lands in git, and private repos show it to
everyone with access.

```bash
gh pr edit <number> --body-file "$WORK/pr-body-<slice-branch>.md" \
  --attach "$WORK/evidence/<slice-branch>/01-email-rejected.png#Email rejected" \
  --attach "$WORK/evidence/<slice-branch>/flow.webm"
```

- In the body file, point at the exact path given to `--attach`:
  `![Email rejected](<that path>)`.
- Alt text for an image follows `#`; keep the whole argument in quotes.
- A video path needs a line to itself to turn into a player. Videos take no
  alt text.
- Attached files the body never mentions are added at the bottom.
- Images (png, jpg, gif, webp, svg) and video (mp4, mov, webm) only. You need
  push access.
- Proof for a review reply: `gh pr comment <number> --attach …`.

`gh` below 2.99.0: show the user the version and ask them to upgrade; never
upgrade system packages on your own. Until then the PR stays a draft, its body
lists each proof file with its local path, and the slice is not done.

Never upload through a browser extension that needs your session cookie.

## Check the upload

After the edit, make sure the proof is truly in the PR:

```bash
gh pr view <number> --json body --jq .body
gh api "repos/{owner}/{repo}/pulls/<number>" --header "Accept: application/vnd.github.html+json" --jq .body_html
```

1. The body holds no local path any more.
2. The HTML has an `<img>` for each still and a `<video>` for each recording.
3. Each media link answers 200:

```bash
curl --silent --head --location --output /dev/null --write-out '%{http_code}\n' \
  --header "Authorization: Bearer $(gh auth token)" "<url>"
```

A broken image proves nothing. Fix it and check again before the PR goes
ready.
