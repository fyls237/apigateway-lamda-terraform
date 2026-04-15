'use strict';

/**
 * Lambda handler – Data Processing
 *
 * Routes:
 *   GET  /data            → return a sample dataset
 *   POST /data            → transform / validate the submitted JSON payload
 *
 * Supported POST operations (via body.operation):
 *   sum      → returns the sum of body.values (array of numbers)
 *   average  → returns the average of body.values
 *   filter   → returns body.values filtered by body.threshold (>= threshold)
 */
exports.handler = async (event) => {
  const method = event.httpMethod;

  try {
    if (method === 'GET') {
      return respond(200, {
        dataset: [10, 42, 7, 99, 3, 56],
        description: 'Sample numeric dataset',
      });
    }

    if (method === 'POST') {
      const body = parseBody(event.body);
      const { operation, values } = body;

      if (!Array.isArray(values) || values.length === 0) {
        return respond(400, { error: 'values must be a non-empty array' });
      }
      if (!values.every((v) => typeof v === 'number')) {
        return respond(400, { error: 'all values must be numbers' });
      }

      switch (operation) {
        case 'sum':
          return respond(200, { operation, result: values.reduce((a, b) => a + b, 0) });

        case 'average':
          return respond(200, {
            operation,
            result: values.reduce((a, b) => a + b, 0) / values.length,
          });

        case 'filter': {
          const threshold = typeof body.threshold === 'number' ? body.threshold : 0;
          return respond(200, {
            operation,
            threshold,
            result: values.filter((v) => v >= threshold),
          });
        }

        default:
          return respond(400, {
            error: `Unknown operation "${operation}". Supported: sum, average, filter`,
          });
      }
    }

    return respond(405, { error: `Method ${method} not allowed` });
  } catch (err) {
    console.error('data_processing error', err);
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
