const request = require("supertest");
// Test the real server, not a copy of it, so coverage reflects index.js
const app = require("../index");

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
