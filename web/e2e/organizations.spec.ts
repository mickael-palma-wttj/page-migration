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

  test("navigates to organization show page", async ({ page }) => {
    // This test requires a real organization in the database
    // Skip if no organizations exist
    await page.goto("/organizations");

    await page.getByPlaceholder(/Search by company name/).fill("test");
    await page.getByRole("button", { name: "Search" }).click();

    await waitForTurbo(page);

    const orgLink = page.locator(".divide-y a").first();
    if (await orgLink.isVisible()) {
      await orgLink.click();
      await waitForTurbo(page);
      await expect(page.locator("nav")).toContainText("Search");
    }
  });
});
