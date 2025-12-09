# RenderMe NL Cookbook

A lightweight cookbook of RenderMe JSON templates ready for quick API demos. RenderMe (https://renderme.nl) turns JSON templates into MP4 videos—sign up there to get an API key. Use these samples directly in `POST /api/v1/jobs` requests for fast experiments.

## Included templates
- `templates/all_animations_showcase.json` — demonstrates the full animation set.
- `templates/animation_effects_showcase.json` — highlights individual animation/effect variants.
- `templates/basic_slideshow_9x16.json` — portrait slideshow starter.
- `templates/basic_slideshow_16x9.json` — landscape slideshow starter.
- `templates/external_assets_demo.json` — references remote assets instead of local files.
- `templates/tts_demonstration.json` — text-to-speech narration example.

## Usage (4 quick steps)
1) Set your RenderMe API key: `export RENDERME_API_KEY="<rm_api_key>"`.
2) For TTS templates, store your ElevenLabs key via curl:
   ```bash
   curl -X POST "https://renderme.nl/api/v1/users/elevenlabs-key" \
     -H "Authorization: Bearer $RENDERME_API_KEY" \
     -H "Content-Type: application/json" \
     -d '{"elevenlabs_api_key":"<elevenlabs_api_key>"}'
   ```
3) Submit a template job (example):
   ```bash
   curl -X POST "https://renderme.nl/api/v1/jobs" \
     -H "Authorization: Bearer $RENDERME_API_KEY" \
     -H "Content-Type: application/json" \
     -d @templates/basic_slideshow_16x9.json
   ```
4) Poll until complete, then download:
   ```bash
   # Replace <job_id> with the ID from step 3
   curl -X GET "https://renderme.nl/api/v1/jobs/<job_id>" \
     -H "Authorization: Bearer $RENDERME_API_KEY"

   # When status is "completed", download the MP4
   curl -L -o my_video.mp4 "https://renderme.nl/api/v1/jobs/<job_id>/download" \
     -H "Authorization: Bearer $RENDERME_API_KEY"
   ```

## Scripted workflow (no manual curl)
Use `scripts/render_from_template.sh` to submit a template and download the MP4 automatically.

```bash
# From the repo root
export RENDERME_API_KEY="<rm_api_key>"
./scripts/render_from_template.sh templates/basic_slideshow_16x9.json my_video.mp4
```

For TTS templates (e.g., `tts_demonstration.json`), store your ElevenLabs key once before rendering:

```bash
export RENDERME_API_KEY="<rm_api_key>"
./scripts/store_elevenlabs_key.sh <elevenlabs_api_key>
```

Requirements: `curl` and `python3` available on your path.
