module.exports = {
  apps: [
    {
      name: "unstable-backend",
      script: "server.mjs",
      instances: 1,
      exec_mode: "fork",
      env: {
        HOST: "0.0.0.0",
        PORT: "3000"
      }
    }
  ]
};
