'use strict';

/**
 * Lambda handler – User Management
 *
 * Routes:
 *   GET  /users          → list all users
 *   POST /users          → create a new user
 */
exports.handler = async (event) => {
  const method = event.httpMethod;

  try {
    if (method === 'GET') {
      return respond(200, {
        users: [
          { id: '1', name: 'Alice Dupont', email: 'alice@example.com' },
          { id: '2', name: 'Bob Martin', email: 'bob@example.com' },
        ],
      });
    }

    if (method === 'POST') {
      const body = parseBody(event.body);
      if (!body.name || !body.email) {
        return respond(400, { error: 'name and email are required' });
      }
      const newUser = {
        id: generateId(),
        name: body.name,
        email: body.email,
        createdAt: new Date().toISOString(),
      };
      return respond(201, { user: newUser });
    }

    return respond(405, { error: `Method ${method} not allowed` });
  } catch (err) {
    console.error('user_management error', err);
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

function generateId() {
  return Math.random().toString(36).slice(2, 10);
}
