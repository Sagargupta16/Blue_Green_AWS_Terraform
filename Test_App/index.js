const express = require("express");
const app = express();
app.disable("x-powered-by");
const AWSXRay = require("aws-xray-sdk");
app.use(AWSXRay.express.openSegment("Green Blue Deployment Test App"));
AWSXRay.config([AWSXRay.plugins.ECSPlugin]);
const http = AWSXRay.captureHTTPs(require("node:http"));

// Serve static files from the React build directory
app.use(express.static("client/build"));

// Define a route to serve your React app
app.get("/", (req, res) => {
  res.sendFile("index.html", { root: __dirname + "/client/build" });
});

// Additional Routes
app.get("/api/hello", (req, res) => {
  res.json({ message: "Hello, World!" });
});

app.get("/api/goodbye", (req, res) => {
  res.json({ message: "Goodbye, World!" });
});

app.get("/api/data", (req, res) => {
  res.json({ data: [1, 2, 3, 4, 5] });
});

// Close the X-Ray segment
app.use(AWSXRay.express.closeSegment());

// Start the server only when run directly, so tests can import the app
if (require.main === module) {
  const port = process.env.PORT || 3000;
  app.listen(port, () => {
    console.log(`listening on ${port}`);
  });
}

module.exports = app;
