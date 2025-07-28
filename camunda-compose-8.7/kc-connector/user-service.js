const express = require("express");
const axios = require("axios");
const app = express();
const PORT = 8080;

// Middleware for JSON parsing
app.use(express.json());

// Configuration
const KEYCLOAK_CONFIG = {
  hostname: process.env.HOSTNAME || "camunda.example.com",
  internalHostname: "keycloak",
  adminUsername: process.env.KC_ADMIN_USER || "admin",
  adminPassword: process.env.KC_ADMIN_PASSWORD || "admin",
  realm: "camunda-platform",
};

// Helper function to get access token
async function getAccessToken() {
  try {
    const tokenResponse = await axios.post(
      `http://${KEYCLOAK_CONFIG.internalHostname}:18080/auth/realms/master/protocol/openid-connect/token`,
      new URLSearchParams({
        grant_type: "password",
        client_id: "admin-cli",
        username: KEYCLOAK_CONFIG.adminUsername,
        password: KEYCLOAK_CONFIG.adminPassword,
      }),
      {
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
      }
    );

    return tokenResponse.data.access_token;
  } catch (error) {
    console.error("Error getting access token:", error.message);
    throw error;
  }
}

// Helper function to create a user in Keycloak
async function createUserInKeycloak(userData, accessToken) {
  try {
    const userPayload = {
      username: userData.username,
      email: userData.email,
      firstName: userData.firstname,
      lastName: userData.lastname || "",
      enabled: true,
      emailVerified: true,
      credentials: [
        {
          type: "password",
          value: userData.password,
          temporary: false,
        },
      ],
    };

    const response = await axios.post(
      `http://${KEYCLOAK_CONFIG.internalHostname}:18080/auth/admin/realms/${KEYCLOAK_CONFIG.realm}/users`,
      userPayload,
      {
        headers: {
          Authorization: `Bearer ${accessToken}`,
          "Content-Type": "application/json",
        },
      }
    );

    return response.data;
  } catch (error) {
    console.error(
      "Error creating user:",
      error.response?.data || error.message
    );
    throw error;
  }
}

// POST endpoint for user creation
app.post("/user", async (req, res) => {
  try {
    // Validate input data
    const { username, firstname, email, password } = req.body;

    if (!username || !firstname || !email || !password) {
      return res.status(400).json({
        error: "Missing required fields",
        message: "username, firstname, email and password are required",
      });
    }

    // Email validation
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      return res.status(400).json({
        error: "Invalid email address",
        message: "Please enter a valid email address",
      });
    }

    // Get access token
    const accessToken = await getAccessToken();

    // Create user in Keycloak
    await createUserInKeycloak(
      {
        username,
        firstname,
        email,
        password,
      },
      accessToken
    );

    // Successful response (201 Created)
    res.status(201).json({
      message: "User created successfully",
      username: username,
      email: email,
    });
  } catch (error) {
    console.error("Error during user creation:", error);

    // Specific error handling
    if (error.response?.status === 409) {
      return res.status(409).json({
        error: "User already exists",
        message: "A user with this username or email address already exists",
      });
    }

    if (error.response?.status === 401) {
      return res.status(500).json({
        error: "Authentication error",
        message: "Error authenticating with Keycloak",
      });
    }

    // General error
    res.status(500).json({
      error: "Internal server error",
      message: "Error during user creation",
    });
  }
});

// Health check endpoint
app.get("/health", (req, res) => {
  const now = new Date();
  res.status(200).json({
    status: "OK",
    service: "User Creation Service",
    timestamp: now.toISOString(),
    timezone: Intl.DateTimeFormat().resolvedOptions().timeZone,
    localTime: now.toString(),
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`User Service running on port ${PORT}`);
  console.log(`Keycloak Hostname: ${KEYCLOAK_CONFIG.hostname}`);
  console.log(`Keycloak Realm: ${KEYCLOAK_CONFIG.realm}`);
});

module.exports = app;
