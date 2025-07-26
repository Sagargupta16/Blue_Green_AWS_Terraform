const request = require("supertest");
const express = require("express");
const AWSXRay = require("aws-xray-sdk");
const app = express();

app.use(AWSXRay.express.openSegment("TestApp"));

app.use(express.static("client/build"));

app.get("/", (req, res) => {
  res.sendFile("index.html", { root: __dirname + "/client/build" });
});

app.get("/api/hello", (req, res) => {
  res.json({ message: "Hello, World!" });
});

app.get("/api/goodbye", (req, res) => {
  res.json({ message: "Goodbye, World!" });
});

app.get("/api/data", (req, res) => {
  res.json({ data: [1, 2, 3, 4, 5] });
});

app.use(AWSXRay.express.closeSegment());

describe("GET /api/hello", () => {
  it("should return a hello message", async () => {
    const res = await request(app).get("/api/hello");
    expect(res.statusCode).toEqual(200);
    expect(res.body).toHaveProperty("message", "Hello, World!");
  });
});

describe("GET /api/goodbye", () => {
  it("should return a goodbye message", async () => {
    const res = await request(app).get("/api/goodbye");
    expect(res.statusCode).toEqual(200);
    expect(res.body).toHaveProperty("message", "Goodbye, World!");
  });
});

describe("GET /api/data", () => {
  it("should return an array of data", async () => {
    const res = await request(app).get("/api/data");
    expect(res.statusCode).toEqual(200);
    expect(res.body).toHaveProperty("data");
    expect(res.body.data).toEqual(expect.arrayContaining([1, 2, 3, 4, 5]));
  });
});
