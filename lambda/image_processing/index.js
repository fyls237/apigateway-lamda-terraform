'use strict';

/**
 * Lambda handler – Image Processing
 *
 * Routes:
 *   POST /images          → process a base64-encoded image
 *
 * Supported POST operations (via body.operation):
 *   resize    → returns metadata describing the resize (width × height)
 *   info      → returns basic metadata about the submitted image
 *
 * Note: This handler simulates image processing. In production it would
 *       use a library such as sharp (bundled as a Lambda layer or in the
 *       deployment package) to perform the actual transformations.
 */
exports.handler = async (event) => {
  const method = event.httpMethod;

  try {
    if (method !== 'POST') {
      return respond(405, { error: `Method ${method} not allowed` });
    }

    const body = parseBody(event.body);
    const { image, operation } = body;

    if (!image || typeof image !== 'string') {
      return respond(400, { error: 'image (base64 string) is required' });
    }

    // Estimate raw byte size from base64 length
    const estimatedBytes = Math.floor((image.length * 3) / 4);

    switch (operation) {
      case 'resize': {
        const width = typeof body.width === 'number' && body.width > 0 ? body.width : 200;
        const height = typeof body.height === 'number' && body.height > 0 ? body.height : 200;
        return respond(200, {
          operation,
          result: {
            message: `Image would be resized to ${width}x${height}`,
            originalSizeBytes: estimatedBytes,
            targetWidth: width,
            targetHeight: height,
          },
        });
      }

      case 'info':
        return respond(200, {
          operation,
          result: {
            sizeBytes: estimatedBytes,
            format: 'unknown (simulated)',
            processedAt: new Date().toISOString(),
          },
        });

      default:
        return respond(400, {
          error: `Unknown operation "${operation}". Supported: resize, info`,
        });
    }
  } catch (err) {
    console.error('image_processing error', err);
    return respond(500, { error: 'Internal server error' });
  }
};

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

function respond(statusCode, body) {
  return {
    statusCode,
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  };
}

function parseBody(raw) {
  if (!raw) return {};
  try {
    return JSON.parse(raw);
  } catch {
    return {};
  }
}
