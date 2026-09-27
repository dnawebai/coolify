# iQuash OCR stack for Coolify

This stack runs the two private document engines used by iQuash:

- **PaddleOCR / PP-StructureV3** — primary OCR/layout engine
- **Docling** — secondary parser and independent document-structure cross-check

## Coolify deployment

Create a Docker Compose resource from this repository and use:

`iquash/docker-compose.ocr.yml`

Required secrets:

- `IQUASH_OCR_API_KEY`
- `IQUASH_DOCLING_API_KEY`

Optional limits:

- `IQUASH_OCR_MAX_UPLOAD_BYTES=31457280`
- `IQUASH_DOCLING_MAX_UPLOAD_BYTES=31457280`

Both services expose port 8080 only inside the Docker network. In Coolify, attach separate HTTPS domains to each service if external access from Vercel is required.

Recommended domains:

- `ocr.iquash.com` → PaddleOCR
- `docling.iquash.com` → Docling

The iQuash Vercel project should then receive:

- `IQUASH_OCR_URL=https://ocr.iquash.com`
- `IQUASH_OCR_API_KEY=<matching PaddleOCR secret>`
- `IQUASH_DOCLING_URL=https://docling.iquash.com`
- `IQUASH_DOCLING_API_KEY=<matching Docling secret>`

Keep the API keys server-side only.
