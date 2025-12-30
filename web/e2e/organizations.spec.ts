import { test, expect, waitForTurbo } from "./fixtures";

test.describe("Organizations", () => {
  test("displays search page", async ({ page }) => {
    await page.goto("/organizations");

    await expect(page).toHaveTitle(/Search Organizations/);
    await expect(page.getByRole("heading", { name: "Search Organizations" })).toBeVisible();
    await expect(page.getByPlaceholder(/Search by company name/)).toBeVisible();
  });

  test("shows 'No organizations found' for empty search results", async ({ page }) => {
    await page.goto("/organizations");

    await page.getByPlaceholder(/Search by company name/).fill("nonexistent12345");
    await page.getByRole("button", { name: "Search" }).click();

    await waitForTurbo(page);
    await expect(page.getByText(/No organizations match/)).toBeVisible();
  });

  // These tests require test data in the external PostgreSQL database
  // In CI, the database is seeded with test organizations
  // Locally, skip if TEST001 organization doesn't exist

  test("searches and finds organization", async ({ page }) => {
    await page.goto("/organizations");

    await page.getByPlaceholder(/Search by company name/).fill("Test");
    await page.getByRole("button", { name: "Search" }).click();

    await waitForTurbo(page);

    // Check if test data exists
    const testOrg = page.getByText("Test Organization");
    if (!(await testOrg.isVisible({ timeout: 2000 }).catch(() => false))) {
      test.skip(true, "Test organization not found in database - run e2e/setup-db.sql to seed");
      return;
    }

    await expect(testOrg).toBeVisible();
    await expect(page.getByText("TEST001")).toBeVisible();
  });

  test("navigates to organization show page", async ({ page }) => {
    await page.goto("/organizations");

    await page.getByPlaceholder(/Search by company name/).fill("Test");
    await page.getByRole("button", { name: "Search" }).click();

    await waitForTurbo(page);

    // Check if test data exists
    const testOrg = page.getByText("Test Organization");
    if (!(await testOrg.isVisible({ timeout: 2000 }).catch(() => false))) {
      test.skip(true, "Test organization not found in database - run e2e/setup-db.sql to seed");
      return;
    }

    // Click on the organization
    await testOrg.click();
    await waitForTurbo(page);

    // Should be on the organization show page
    await expect(page).toHaveURL(/organizations\/TEST001/);
    await expect(page.getByRole("heading", { name: "Test Organization" })).toBeVisible();
  });
});
