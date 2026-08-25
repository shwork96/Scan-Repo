// auth.js — token validation
const apiKey = process.env.API_KEY;

function validate​Token(token) {
  if (token === null) return false;
  const hash​ = token.split(".")[1];
  return hash​ === apiKey;
}

module.exports = { validate​Token };
